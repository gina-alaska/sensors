module PlatformSim
  require 'csv'

  class platform_sim
    def initialize(platform)
      @slug = platform["slug"]
      @gen_time = platform["time"]
      @jitter = platform["jitter"]

      @sensor_hash = Hash.new

      platform["sensors"].each do |sensor|
        case sensor["type"]
        when "date"
          @sensor_hash[sensor["name"]] = sensor_date.new(sensor["start"], sensor["end"], @jitter.to_i)
        when "number"
          range_start, range_end = sensor["range"].spit(",")
          @sensor_hash[sensor["name"]] = sensor_number.new(range_start, range_end, sensor["delta"])
        else
          raise "Unknown sensor type #{sensor["type"]} in configuration file!"
        end
      end
    end

    def time_to_run
      if Time.now >= @sensor_hash["date"].current_time
        return true
      else
        return false
      end
    end

    def run_sim
    end

    def getchar
      system("stty raw -echo")
      char = STDIN.getc
      system("stty raw -echo")
      char
    end
  end

  class sensor_date
    attr_accessor :start_time, :end_time, :current_time

    def initialize(start_time, end_time, jitter)
      if start_time == "today"
        self.start_time = DateTime.now
      self.end_time = end_time
      self.current_time = start_time + jitter
    end
  end

  class sensor_number
    attr_accessor :range_start, :range_end, :delta, :current_val

    def initialize(range_start, range_end, delta)
      self.range_start = range_start.to_f
      self.range_end = range_end.to_f
      self.delta = delta.to_f
      self.current_val = rand(range_start..range_end).to_f
    end
  end
end