# Draw a depth graph from the data
module RvgGraph
  class DepthGraph
    def self.draw(data, bcord, agg, canvas)
      x_min = bcord.xmin
      x_max = bcord.xmax
      y_min = bcord.ymin
      y_max = bcord.ymax

      dstyle = Style.new(data["style"])
      direction = data["direction"]
      range = data["range"].split(",")
      top = range[0].to_f
      bottom = range[1].to_f
      data_top = data["graph_top"]

      maxval = agg.maxval.to_f * -1.0

      hard_min = data["hard_min"].nil? ? nil : data["hard_min"].to_f
      hard_max = data["hard_max"].nil? ? nil : data["hard_max"].to_f
      oldrange = hard_max - hard_min
      newrange = bottom - top

      convert = CalcPosition.new(top, bottom, data_top, oldrange, newrange, hard_min, 0)
      data_min = convert.calc(0, false)
      data_max = convert.calc(maxval, false)

      # Draw fill
      if dstyle.fill_color
        canvas.rect(x_max - x_min, data_max-data_min, x_min, data_min).styles(:fill=>dstyle.fill_color)
      end

      # Draw boundry lines
      canvas.line(x_min, data_min, x_max, data_min).styles(:stroke_width=>dstyle.line_size, :stroke_dasharray=>dstyle.line_type, :fill=>'none', :stroke=>dstyle.color )
      canvas.line(x_min, data_max, x_max, data_max).styles(:stroke_width=>dstyle.line_size, :stroke_dasharray=>dstyle.line_type, :fill=>'none', :stroke=>dstyle.color )
    end
  end
end
