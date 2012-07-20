# Generates a background image for graph
require 'rvg/rvg'

module RvgGraph
  class Background
    include Magick
    
    def self.generate(graph)
      bg_color = "rgb(#{graph["background_color"]})"
      img_x = graph["width"].to_i
      img_y = graph["height"].to_i
      image = Image.new(img_x, img_y) {
        self.background_color = bg_color
      }

      unless graph["graph_gradients"].nil?
        bounds = graph["graph_bounds"]
        img_bounds = bounds.split(",")
        gradimg = gradients(bounds, graph["graph_gradients"])
        image = image.composite(gradimg, img_bounds[0].to_i, img_bounds[1].to_i, OverCompositeOp)
      end
      return image
    end

    def self.gradients(bounds, gradients)
      img_bounds = bounds.split(",")
      img_x = img_bounds[2].to_i - img_bounds[0].to_i
      img_y = img_bounds[3].to_i - img_bounds[1].to_i
      backimg = Image.new(img_x, img_y)

      gradients.each do |grade|
        c1 = "rgb(#{grade["color1"]})"
        c2 = "rgb(#{grade["color2"]})"
        start = grade["start"].split(",")
        height ||= grade["height"]
        width ||= grade["width"]
        pos = grade["position"].split(",")
        op = grade["opacity"].to_f

        gimg_x = img_x
        gimg_y = img_y
        gimg_x = img_x if gimg_x == 0
        gimg_y = height if height
        gfill = GradientFill.new(start[0].to_i, start[1].to_i, start[2].to_i, start[3].to_i, c1, c2)
        gradimg = Image.new(gimg_x, gimg_y, gfill)
        backimg = backimg.dissolve(gradimg, op, 1.0, pos[0].to_i, pos[1].to_i)
      end

      return backimg
    end
  end
end
