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

      data["axis"].each do |daxis|
        hard_min = data["hard_min"].nil? ? nil : data["hard_min"].to_f
        hard_max = data["hard_max"].nil? ? nil : data["hard_max"].to_f
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
            gmin = x_min
            gmax = x_max
          else
            gmin = range_min
            gmax = range_max
          end
        when "y"
          if data["direction"] == "y-axis"
            gmin = y_min
            gmax = y_max
          else
            gmin = range_min
            gmax = range_max
          end
        end

        label = daxis["label"]
        dmin = agg.minval.to_f
        dmax = agg.maxval.to_f
        dmin = hard_min unless hard_min.nil?
        dmax = hard_max unless hard_max.nil?
        hard_min = dmin if hard_min.nil?
        hard_max = dmax if hard_max.nil?

        # date axis
        if label["units"] == "date"
          dmin = agg.capture_min
          dmax = agg.capture_max
          hard_max = dmax
        end

        # Convert units if needed
        offset = 0
        unless label["units"].nil? or data["units"] == label["units"] or label["units"] == "date"
          dmin = LabelHelpers.conv_units(data["units"], label["units"], dmin).to_f
          dmax = LabelHelpers.conv_units(data["units"], label["units"], dmax).to_f
          hard_max = LabelHelpers.conv_units(data["units"], label["units"], hard_max).to_f
        end

        # Find nice number range for axis tics/labels
        unless label["units"] == "date"
          nice_range = Nicenum.calc(dmax - dmin, false)
          nice_tic_delta = Nicenum.calc(nice_range/(major_tics - 1), true).to_f
          nice_min = (dmin / nice_tic_delta).floor * nice_tic_delta
          nice_max = (dmax / nice_tic_delta).ceil * nice_tic_delta
          minor_delta = nice_tic_delta / minor_tics unless minor_tics.nil?
        else
          drange = dmax.utc.to_i - dmin.utc.to_i
          nice_min = dmin.utc.to_i
          nice_max = dmax.utc.to_i
          if drange <= 3600           # 1 hour
            nice_tic_delta = 300      # 5 min
            minor_delta = 30          # 30 sec
            offset = Nicenum.date_floor(dmin, "hour").utc.to_i - dmin.utc.to_i
          elsif drange <= 86400       # 1 day
            nice_tic_delta = 3600     # 1 hour
            minor_delta = 600         # 10 min
            offset = Nicenum.date_floor(dmin, "day").utc.to_i - dmin.utc.to_i
          elsif drange <= 604800      # 1 week
            nice_tic_delta = 86400    # 1 day
            minor_delta = 10800       # 3 hours
            offset = Nicenum.date_floor(dmin, "week").utc.to_i - dmin.utc.to_i
          elsif drange <= 2678400     # 1 month
            nice_tic_delta = 86400    # 1 day
            minor_delta = 43200       # 12 hours
            offset = Nicenum.date_floor(dmin, "month").utc.to_i - dmin.utc.to_i
          else                        # 1 year
            nice_tic_delta = 2678400  # month
            minor_delta = 86400       # 1 day
            offset = Nicenum.date_floor(dmin, "year").utc.to_i - dmin.utc.to_i
          end
        end

        # Draw major tics and labels
        pos = nice_min - nice_tic_delta
        round = label["round"]
        dmin = dmin.utc.to_i if label["units"] == "date"
        dmax = dmax.utc.to_i if label["units"] == "date"
        hard_max = hard_max.utc.to_i if label["units"] == "date"
        convert = CalcPosition.new(gmin, gmax, data_top, dmax-dmin, gmax-gmin, dmin, offset)

        while pos <= nice_max do 
          gpos = convert.calc_axis(pos, false)
          ttext = pos
          ttext = Time.at(pos).utc.strftime("%d %b") if label["units"] == "date"

          if gpos >= gmin and gpos <= gmax
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
          end

          unless minor_tics.nil? or pos == nice_max + nice_tic_delta
            mtic = pos - nice_tic_delta
            while mtic <= (pos + nice_tic_delta)
              mpos = convert.calc_axis(mtic, false)

              if mpos > gmin and mpos < gmax
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