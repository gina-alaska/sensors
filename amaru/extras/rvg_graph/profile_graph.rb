module RvgGraph
  class ProfileGraph
    def self.draw(data, bcord, canvas, data_hash, no_data)
      x_min = bcord.xmin
      x_max = bcord.xmax
      y_min = bcord.ymin
      y_max = bcord.ymax
      dstyle = Style.new(data["style"])

      agg_data = Array.new

      range = data["range"].split(",")
      top = range[0].to_f
      bottom = range[1].to_f

      hard_min = data["hard_min"].nil? ? nil : data["hard_min"].to_f
      hard_max = data["hard_max"].nil? ? nil : data["hard_max"].to_f
      phard_min = data["profile_min"].nil? ? nil : data["profile_min"].to_f
      phard_max = data["profile_max"].nil? ? nil : data["profile_max"].to_f

      # Get aggrigate data for each field
      data_fields = data["name"].split(",")
      data_fields.each do |field|
        agg_data.push(Agg.new(data_hash, field, no_data))
      end

      oldrange = hard_max - hard_min
      convertx = CalcPosition.new(x_min, x_max, "negative", oldrange, x_max-x_min, hard_min, 0)
      converty = CalcPosition.new(y_min, y_max, "positive", phard_max-phard_min, y_max-y_min, phard_min, 0)

      # draw profile fill
      y_start = 0.7          # start position of profile (this should be from database)
      y_end = y_start-(agg_data.count * 0.1)+0.1  # end position of profile (database too)

      first_min = agg_data[0].minval
      first_max = agg_data[0].maxval
      path = "M "
      path += "#{convertx.calc(first_min, false).to_i} #{converty.calc(y_start, false).to_i} L "
      path += "#{convertx.calc(first_max, false).to_i} #{converty.calc(y_start, false).to_i} L "

      y_pos = y_start
      agg_data.each do |agg|
        path += "#{convertx.calc(agg.maxval, false).to_i} #{converty.calc(y_pos, false).to_i} L "
        y_pos -= 0.1  # this value should be calculated from database fields
      end

      last_min = agg_data[agg_data.count-1].minval
      last_max = agg_data[agg_data.count-1].maxval
      path += "#{convertx.calc(last_max, false).to_i} #{converty.calc(y_end, false).to_i} L "
      path += "#{convertx.calc(last_min, false).to_i} #{converty.calc(y_end, false).to_i} L "

      y_pos = y_end
      agg_data.reverse_each do |agg|
        if y_pos >= y_start-0.1
          path += "#{convertx.calc(agg.minval, false).to_i} #{converty.calc(y_pos, false).to_i} z "
        else
          path += "#{convertx.calc(agg.minval, false).to_i} #{converty.calc(y_pos, false).to_i} L "
        end
        y_pos += 0.1  # this value should be calculated from database fields
      end

      canvas.path(path).styles(:stroke=>dstyle.fill_color, :fill=>dstyle.fill_color, :stroke_width=>"0.8")

      # Draw profile lines
      save_min = agg_data[0].minval
      save_max = agg_data[0].maxval
      y_pos = 0.7
      ysave = 0.7

      agg_data.each do |agg|
        if agg.maxval == save_max
          y_pos -= 0.1
          next
        end
        y1pos = converty.calc(ysave, false)
        y2pos = converty.calc(y_pos, false)

        x1pos = convertx.calc(save_max, false)
        x2pos = convertx.calc(agg.maxval, false)
        canvas.line(x1pos, y1pos, x2pos, y2pos).styles(:stroke=>dstyle.profile_color, :stroke_width=>dstyle.line_size)

        x1pos = convertx.calc(save_min, false)
        x2pos = convertx.calc(agg.minval, false)
        canvas.line(x1pos, y1pos, x2pos, y2pos).styles(:stroke=>dstyle.profile_color, :stroke_width=>dstyle.line_size)

        save_min = agg.minval
        save_max = agg.maxval
        ysave = y_pos
        y_pos -= 0.1
      end

      # Draw current values
      xsave = data_hash[data_fields[0]][0]
      ypos = 0.7
      ysave = 0.7
      x2pos = 0
      y2pos = 0
      data_fields.each do |field|
        if ysave == ypos
          ypos -= 0.1
          next
        end
        y1pos = converty.calc(ysave, false)
        y2pos = converty.calc(ypos, false)

        dpos = data_hash[field][0]
        x1pos = convertx.calc(xsave, false)
        x2pos = convertx.calc(dpos, false)
        
        canvas.line(x1pos, y1pos, x2pos, y2pos).styles(:stroke=>dstyle.color, :stroke_width=>dstyle.line_size)
        canvas.circle(dstyle.dot_size, x1pos, y1pos).styles(:stroke=>dstyle.color, :fill=>dstyle.color, :stroke_width=>1)

        ysave = ypos
        xsave = dpos
        ypos -= 0.1
      end
      canvas.circle(dstyle.dot_size, x2pos, y2pos).styles(:stroke=>dstyle.color, :fill=>dstyle.color, :stroke_width=>1)
    end
  end
end
