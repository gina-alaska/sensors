# Draw graph border
module RvgGraph
  class Border
    include Magick
    
    def self.draw(border_object, bcord, canvas)
      bstyle = Style.new(border_object["style"])

      # Clean up border area
      (1..4).each do |num|
        numt = num*2
        canvas.rect((bcord.xmax-bcord.xmin)+numt, (bcord.ymax-bcord.ymin)+numt, bcord.xmin-num, bcord.ymin-num).styles(:stroke=>bstyle.fill_color, :stroke_width=>bstyle.line_size, :fill_opacity=>0)
      end

      # Draw border
      canvas.rect(bcord.xmax-bcord.xmin, bcord.ymax-bcord.ymin, bcord.xmin, bcord.ymin).styles(:stroke=>bstyle.color, :stroke_width=>bstyle.line_size, :fill_opacity=>0)

      # Build break lines
      if border_object["break_line"]
        blbox = border_object["break_line"].split(",")
        y_pos = blbox[0].to_i
        skew = blbox[3].to_i
        width = blbox[1].to_i
        thick = blbox[2].to_i
        break_line = RVG::Group.new do |bline|
          bline.rect(width,thick,0,0).styles(:fill=>bstyle.fill_color, :stroke=>bstyle.fill_color)
          bline.line(0,0,width,0).styles(:stroke=>bstyle.color, :stroke_width=>bstyle.line_size+0.5)
          bline.line(0,thick,width,thick).styles(:stroke=>bstyle.color, :stroke_width=>bstyle.line_size+0.5)
          bline.translate(-width/2)
        end
        # Draw break lines
        canvas.g.translate(bcord.xmin, y_pos) do |grp|
          grp.use(break_line, 0, 0)
          grp.skewY(skew)
        end
        canvas.g.translate(bcord.xmax, y_pos) do |grp|
          grp.use(break_line, 0, 0)
          grp.skewY(skew)
        end
      end
    end
  end
end