# Draw graph axis
module RvgGraph
  class Axis
    def self.draw(data, bcord, agg, canvas)
      x_min = bcord.xmin
      x_max = bcord.xmax
      y_min = bcord.ymin
      y_max = bcord.ymax
      range = data["range"].split(",")
      range_min = range[0].to_f
      range_max = range[1].to_f
      data_top = data["graph_top"]
      hard_min = data["hard_min"].nil? ? nil : data["hard_min"].to_f
      hard_max = data["hard_max"].nil? ? nil : data["hard_max"].to_f

      data["axis"].each do |daxis|
        dstyle = Style.new(daxis["style"])
        place = daxis["placement"]
        direction = "x" if place == "top" or place == "bottom"
        direction = "y" if place == "left" or place == "right"
        major_tics = daxis["major"].to_f
        minor_tics = daxis["minor"].to_f
        major_ticlen ||= daxis["major_len"].to_i
        minor_ticlen ||= daxis["minor_len"].to_i
        tic_offset = daxis["offset"].to_i

        case direction
        when "x"
          if data["direction"] == "x-axis"
            gmax = x_max
            gmin = x_min
          else
            gmax = range_max
            gmin = range_min
          end
        when "y"
          if data["direction"] == "y-axis"
            gmax = y_max
            gmin = y_min
          else
            gmax = range_max
            gmin = range_min
          end
        end

        label = daxis["label"]
        dmax = agg.maxval.to_f
        dmin = agg.minval.to_f
        dmin = hard_min unless hard_min.nil?
        dmax = hard_max unless hard_max.nil?
        hard_min = dmin if hard_min.nil?
        hard_max = dmax if hard_max.nil?

        # date axis
        if label["units"] == "date"
          dmin = agg.capture_min.utc.to_i
          dmax = agg.capture_max.utc.to_i
          hard_max = dmax
        end

        # Convert units if needed
        conv_offset = 0
        unless label["units"].nil? or data["units"] == label["units"]
          dmin = LabelHelpers.conv_units(data["units"], label["units"], dmin).to_f
          dmax = LabelHelpers.conv_units(data["units"], label["units"], dmax).to_f
          hard_max = LabelHelpers.conv_units(data["units"], label["units"], hard_max).to_f
          conv_offset = dmin - dmin.to_i
        end

        # Find nice number range for axis tics/labels
        unless label["units"] == "date"
          nice_range = Nicenum.calc(dmax - dmin, false)
          nice_tic_delta = Nicenum.calc(nice_range/(major_tics - 1), true).to_f
          nice_min = (dmin / nice_tic_delta).floor * nice_tic_delta
          nice_max = (dmax / nice_tic_delta).ceil * nice_tic_delta
          minor_delta = nice_tic_delta / minor_tics unless minor_tics.nil?
        else
          drange = dmax - dmin
          nice_min = dmin
          nice_max = dmax
          if drange < 3600            # 1 hour
            nice_tic_delta = 300      # 5 min
            minor_delta = 30          # 30 sec
          elsif drange < 86400        # 1 day
            nice_tic_delta = 3600     # 1 hour
            minor_delta = 600         # 10 min
          elsif drange < 604800       # 1 week
            nice_tic_delta = 86400    # 1 day
            minor_delta = 3600        # 1 hour
          elsif drange < 2678400      # 1 month
            nice_tic_delta = 86400    # 1 day
            minor_delta = 43200       # 12 hours
          else
            nice_tic_delta = 2678400  # month
            minor_delta = 86400       # 1 day
          end
        end

        unless conv_offset == 0
          nice_max -= nice_tic_delta
          nice_min += nice_tic_delta
          x_max -= nice_tic_delta
          x_min += nice_tic_delta
        end

        # Draw major tics and labels
        pos = nice_min
        round = label["round"]

        while pos <= nice_max do 
          if data_top == "negative"  # THIS NEEDS WORK, NOT DONE YET!!
            if direction == "x" and data["direction"] == "x-axis"
              gpos = (((pos - nice_min + conv_offset) * (gmax-gmin)) / (dmax-dmin)) + x_min
            else
              gpos = (((pos - nice_min - conv_offset) * (gmax-gmin)) / (dmax-dmin)) + range_min
            end
          else
            if direction == "x" and data["direction"] == "x-axis"
              gpos = x_max - (((pos - nice_min + conv_offset) * (gmax-gmin)) / (dmax-dmin))
            else
              gpos = range_max - (((pos - nice_min - conv_offset) * (gmax-gmin)) / (dmax-dmin))
            end
          end
          ttext = pos
          ttext = Time.at(pos).utc.strftime("%d %b") if label["units"] == "date"

          case place
          when "top"
            canvas.line(gpos.to_i, y_min.to_i, gpos.to_i, (y_min + major_ticlen).to_i).styles(:stroke=>dstyle.color, :stroke_width=>dstyle.line_size)
            canvas.text(gpos.to_i, y_min.to_i - tic_offset, LabelHelpers.format(ttext, round)).styles(:fill=>dstyle.color, :font_size=>dstyle.text_size, :font_family=>'Verdana', :text_anchor=>"middle")
          when "bottom"
            canvas.line(gpos.to_i, y_max.to_i, gpos.to_i, (y_max - major_ticlen).to_i).styles(:stroke=>dstyle.color, :stroke_width=>dstyle.line_size)
            canvas.text(gpos.to_i, y_max.to_i + tic_offset, LabelHelpers.format(ttext, round)).styles(:fill=>dstyle.color, :font_size=>dstyle.text_size, :font_family=>'Verdana', :text_anchor=>"middle")
          when "left"
            canvas.line(x_min.to_i, gpos.to_i, (x_min + major_ticlen).to_i, gpos.to_i).styles(:stroke=>dstyle.color, :stroke_width=>dstyle.line_size)
            canvas.text(x_min.to_i - tic_offset, gpos.to_i, LabelHelpers.format(ttext, round)).styles(:fill=>dstyle.color, :font_size=>dstyle.text_size, :font_family=>'Verdana', :text_anchor=>"end", :baseline_shift=>-((dstyle.text_size-2)/2))
          when "right"
            canvas.line(x_max.to_i, gpos.to_i, (x_max - major_ticlen).to_i, gpos.to_i).styles(:stroke=>dstyle.color, :stroke_width=>dstyle.line_size)
            canvas.text(x_max.to_i + tic_offset, gpos.to_i, LabelHelpers.format(ttext, round)).styles(:fill=>dstyle.color, :font_size=>dstyle.text_size, :font_family=>'Verdana', :text_anchor=>"end", :baseline_shift=>-((dstyle.text_size-2)/2))
          end

          unless minor_tics.nil? or pos == nice_max
            mtic = pos
            while mtic <= (pos + nice_tic_delta)
              if data_top == "negative"  # THIS NEEDS WORK, NOT DONE YET!!
                if direction == "x" and data["direction"] == "x-axis"
                  mpos = (((mtic - nice_min) * (gmax-gmin)) / (dmax-dmin)) + x_min
                else
                  mpos = (((mtic - nice_min) * (gmax-gmin)) / (dmax-dmin)) + range_min
                end
              else
                if direction == "x" and data["direction"] == "x-axis"
                  mpos = x_max - (((mtic - nice_min) * (gmax-gmin)) / (dmax-dmin))
                else
                  mpos = range_max - (((mtic - nice_min) * (gmax-gmin)) / (dmax-dmin))
                end
              end
              case place
              when "top"
                canvas.line(mpos.to_i, y_min.to_i, mpos.to_i, (y_min + minor_ticlen).to_i).styles(:stroke=>dstyle.color, :stroke_width=>dstyle.line_size)
              when "bottom"
                canvas.line(mpos.to_i, y_max.to_i, mpos.to_i, (y_max - minor_ticlen).to_i).styles(:stroke=>dstyle.color, :stroke_width=>dstyle.line_size)
              when "left"
                canvas.line(x_min.to_i, mpos.to_i, (x_min + minor_ticlen).to_i, mpos.to_i).styles(:stroke=>dstyle.color, :stroke_width=>dstyle.line_size)
              when "right"
                canvas.line(x_max.to_i, mpos.to_i, (x_max - minor_ticlen).to_i, mpos.to_i).styles(:stroke=>dstyle.color, :stroke_width=>dstyle.line_size)
              end
              mtic += minor_delta
            end
          end

          pos += nice_tic_delta
          break if pos > hard_max 
        end

        # Draw axis label
        lpos = (gmax - gmin)/2 + gmin
        text_style = {:fill=>dstyle.color, :font_size=>label["size"].to_i, :font_family=>'Verdana', :text_anchor=>'middle', :baseline_shift=>-((label["size"]-2)/2)}

        case place
        when "top"
          canvas.styles(text_style) do |txt|
            txt.g.translate(lpos, y_min-label["offset"]) do |grp|
              label["text"].split("\n").each_with_index do |line, index|
                grp.text(0, 0).tspan(line).d(0,label["size"] * index)
              end
              grp.rotate(label["rotate"]) if label["rotate"]
            end
          end
        when "bottom"
          canvas.styles(text_style) do |txt|
            txt.g.translate(lpos, y_max+label["offset"]) do |grp|
              label["text"].split("\n").each_with_index do |line, index|
                grp.text(0, 0).tspan(line).d(0,label["size"] * index)
              end
              grp.rotate(label["rotate"]) if label["rotate"]
            end
          end
        when "left"
          canvas.styles(text_style) do |txt|
            txt.g.translate(x_min-label["offset"], lpos) do |grp|
              label["text"].split("\n").each_with_index do |line, index|
                grp.text(0, 0).tspan(line).d(0,label["size"] * index)
              end
              grp.rotate(label["rotate"]) if label["rotate"]
            end
          end
        when "right"
          canvas.styles(text_style) do |txt|
            txt.g.translate(x_max+label["offset"], lpos) do |grp|
              label["text"].split("\n").each_with_index do |line, index|
                grp.text(0, 0).tspan(line).d(0,label["size"] * index)
              end
              grp.rotate(label["rotate"]) if label["rotate"]
            end
          end
        end
      end
    end
  end
end