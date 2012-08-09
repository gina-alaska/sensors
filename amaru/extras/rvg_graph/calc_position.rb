# This converts data value to graph position
module RvgGraph
  class CalcPosition
    attr_accessor :oldrange, :newrange, :top, :bottom, :data_top, :minval, :offset

    def initialize(top, bottom, data_top, oldrange, newrange, minval, offset)
      self.top = top
      self.bottom = bottom
      self.data_top = data_top
      self.oldrange = oldrange
      self.newrange = newrange
      self.minval = minval
      self.offset = offset
    end

    def calc(data, absolute)
      if absolute
        return ((data - self.minval) * self.newrange) / self.oldrange
      end
      case self.data_top
      when "negative"
        newdata = (((data - self.minval) * self.newrange) / self.oldrange) + self.top
      when "positive"
        newdata = self.bottom - (((data - self.minval) * self.newrange) / self.oldrange)
      else
        puts "Unknown graph_top #{self.data_top}!"
        raise
      end
      return newdata
    end

    def calc_axis(data, absolute)
      if absolute
        return ((data - self.minval) * self.newrange) / self.oldrange
      end
      case self.data_top
      when "negative"
        newdata = (((data - self.minval + self.offset) * self.newrange) / self.oldrange) + self.top
      when "positive"
        newdata = self.bottom - (((data - self.minval - self.offset) * self.newrange) / self.oldrange)
      else
        puts "Unknown graph_top #{self.data_top}!"
        raise
      end
      return newdata
    end
  end
end
