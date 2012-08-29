module PlatformSim
  require 'active_support/all'

  class Platform_sim
    def initialize(platform)
      @slug = platform["slug"]
      @gen_time = platform["time"].to_i
      @jitter = platform["jitter"]

      @sensor_hash = Hash.new

      platform["sensors"].each do |sensor|
        case sensor["type"]
        when "date"
          @sensor_hash[sensor["name"]] = SensorDate.new(sensor["start"], sensor["end"], @jitter.to_i)
        when "number"
          range_start, range_end = sensor["range"].split(",")
          @sensor_hash[sensor["name"]] = SensorNumber.new(range_start, range_end, sensor["delta"])
        else
          raise "Unknown sensor type #{sensor["type"]} in configuration file!"
        end
      end
    end

    def time_to_run
      if DateTime.now >= @sensor_hash["date"].current_time
        return true
      else
        return false
      end
    end

    def run_sim
      data_header = ["date"]
      data_values = [@sensor_hash["date"].current_time]
      @sensor_hash["date"].current_time = @sensor_hash["date"].current_time + @gen_time.seconds

      @sensor_hash.each do |name, sensor|
        unless name == "date"
          data_header.push name
          data_values.push sensor.current_val.to_s
          sensor.current_val = calculate_val(sensor)
        end
      end

      return data_header.join(",") + "\n" + data_values.join(",")
    end

    def calculate_val(sensor)
      value = sensor.current_val
      startval = -1 * sensor.delta
      new_delta = rand * (startval - sensor.delta) - startval
      new_delta = new_delta * -1 if value + new_delta > sensor.range_end || value + new_delta < sensor.range_start

      return sensor.current_val + new_delta
    end
  end

  class SensorDate
    attr_accessor :start_time, :end_time, :current_time

    def initialize(start_time, end_time, jitter)
      if start_time == "today"
        self.start_time = DateTime.now
      else
        self.start_time = DateTime.parse(start_time)
      end

      self.end_time = end_time
      delay = rand(jitter)
      self.current_time = self.start_time + delay.seconds
    end
  end

  class SensorNumber
    attr_accessor :range_start, :range_end, :delta, :current_val

    def initialize(range_start, range_end, delta)
      self.range_start = range_start.to_i
      self.range_end = range_end.to_i
      self.delta = delta.to_f
      self.current_val = (rand * (self.range_start - self.range_end) - self.range_start).to_f
    end
  end
end