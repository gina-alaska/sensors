# Calculate aggregate information from data
require "csv"

module RvgGraph
  class Agg
    attr_accessor :maxval, :minval, :count, :capture_min, :capture_max

    def initialize(data, name, no_data_value)
      name = name.split(",").first
      date ||= data["date"]

      cnt = 0
      data[name].each_with_index do |value, index|
        date_val = date.nil? ? index : date[index]

        unless value == no_data_value.to_f
          self.maxval = value if self.maxval.nil? || value > self.maxval
          self.minval = value if self.minval.nil? || value < self.minval
          self.capture_min = date_val if self.capture_min.nil? || date_val < self.capture_min
          self.capture_max = date_val if self.capture_max.nil? || date_val > self.capture_max
          cnt = index
        end
      end
      self.count = cnt
    end
  end
end
