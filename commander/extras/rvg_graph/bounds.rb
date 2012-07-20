# Pull graph boundry from template
module RvgGraph
  class Bounds
    attr_accessor :xmin, :xmax, :ymin, :ymax, :x_len, :y_len

    def initialize(bounds)
      bcord = bounds.split(",")
      self.xmin = bcord[0].to_f
      self.xmax = bcord[2].to_f
      self.ymin = bcord[1].to_f
      self.ymax = bcord[3].to_f
      self.x_len = self.xmax - self.xmin
      self.y_len = self.ymax - self.ymin
    end
  end
end