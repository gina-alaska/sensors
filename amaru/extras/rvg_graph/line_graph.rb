# Draw a line graph from the data
module RvgGraph
  class LineGraph
    def self.draw(data, bcord, agg, canvas, data_hash, no_data_value)
      x_min = bcord.xmin
      x_max = bcord.xmax

      dstyle = Style.new(data["style"])
      direction = data["direction"]
      range = data["range"].split(",")
      top = range[0].to_f
      bottom = range[1].to_f
      unless data["mark"].nil?
        marks = data["mark"].split(",")
        mark_high = marks[1].to_i if marks[0] == "high"
        mark_low = marks[1].to_i if marks[0] == "low"
      end
      data_top = data["graph_top"]
      data_name = data["name"]

puts "maxval: #{agg.maxval} minval: #{agg.minval} count: #{agg.count}"
      maxval = agg.maxval.to_f
      minval = agg.minval.to_f
      count = agg.count.to_f

      data["maxval"] = maxval
      data["minval"] = minval

      hard_min = data["hard_min"].nil? ? nil : data["hard_min"].to_f
      hard_max = data["hard_max"].nil? ? nil : data["hard_max"].to_f

      savemax = maxval
      savemin = minval
      minval = hard_min unless hard_min.nil?
      maxval = hard_max unless hard_max.nil?

      oldrange = (maxval - minval).to_f

      ratiox = (x_max - x_min)/count
      newrange = (bottom - top).to_f
      newx = x_min
      newy = 0

      convert = CalcPosition.new(top, bottom, data_top, oldrange, newrange, minval, 0)

      if dstyle.fill_color
        firstnum = data_hash[data_name].first
        firsty = convert.calc(firstnum, false)
        lastnum = data_hash[data_name].last
        lasty = convert.calc(lastnum, false)

        path = "M "
        data_hash[data_name].each do |vdata|
          if vdata == no_data_value.to_f
            newx += ratiox
            next
          end

          newy = convert.calc(vdata, false)
          path += "#{newx.to_i} #{newy.to_i} L "
          newx += ratiox
        end
        if dstyle.fill_to == "top"
          path += "#{x_max.to_i} #{lasty.to_i} L #{x_max.to_i} #{top.to_i}
          L #{x_min.to_i} #{top.to_i} L #{x_min.to_i} #{firsty.to_i} z"
        else
          path += "#{x_max.to_i} #{lasty.to_i} L #{x_max.to_i} #{bottom.to_i}
               L #{x_min.to_i} #{bottom.to_i} L #{x_min.to_i} 
               #{firsty.to_i} z"
        end
        canvas.path(path).styles(:stroke=>dstyle.fill_color, :fill=>dstyle.fill_color, :stroke_width=>"0.8")
      end

      newx = x_min.to_f
      savx = x_min.to_f
      savy = 0
      dsave = 0

      data_hash[data_name].each_with_index do |vdata, index|
        dsave = vdata
        if vdata == no_data_value.to_f
          savy = 0
          savx = newx
          newx += ratiox
          next
        end

        newy = convert.calc(vdata, false)

        if vdata == savemax and mark_high
          canvas.line(newx, newy-mark_high, newx, newy+mark_high).
              styles(:stroke=>"red")
        end

        if vdata == savemin and mark_low
          canvas.line(newx, newy-mark_low, newx, newy+mark_low).
              styles(:stroke=>"red")
        end

        if savy == 0
          savy = newy
          savx = newx
          newx += ratiox
          next
        else
          canvas.line(savx.to_i, savy.to_i, newx.to_i, newy.to_i).styles(:stroke=>dstyle.color, :stroke_width=>dstyle.line_size, :stroke_linecap=>"round")
        end
        savx = newx
        savy = newy
        newx += ratiox
      end
      canvas.line(savx.to_i, savy.to_i, newx.to_i, savy.to_i).styles(:stroke=>dstyle.color, :stroke_width=>dstyle.line_size, :stroke_linecap=>"round")
    end
  end
end
