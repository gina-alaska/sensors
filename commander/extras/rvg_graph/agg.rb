# Calculate aggregate information from data
module RvgGraph
  class Agg
    attr_accessor :maxval, :minval, :count, :capture_min, :capture_max

    def initialize(collection, field, platform, start_date, end_date)
      case collection
      when "raw"
        data = platform.raw_data.captured_between(start_date, end_date).only(:capture_date, field)
      when "processed"
        data = platform.processed_data.captured_between(start_date, end_date).only(:capture_date, field)
      else
        puts "Unknown collection name #{collection} in graph configuration!"
        raise
      end

      data.each do |datum|
        value = datum[field].to_f
        date = datum[:capture_date]
        unless value == platform.no_data_value.to_f
          self.maxval = value if self.maxval.nil? || value > self.maxval
          self.minval = value if self.minval.nil? || value < self.minval
          self.capture_min = date if self.capture_min.nil? || date < self.capture_min
          self.capture_max = date if self.capture_max.nil? || date > self.capture_max
        end
      end
      self.count = data.count
    end
  end
end