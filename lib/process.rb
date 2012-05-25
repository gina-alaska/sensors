# 
# Process raw sensor data and than populate the processed collection.
#

module Sensors
  module Process

    class DoProcess
      def initialize
      	attr_accessor :process_config

      	@config = Sensors::Config.instance
      	self.process_config = @config["process"]
      	@no_data = self.process_config["no_data"]
      end

      def data_process( start_date, end_date )
      	# Get valid event processes from database
      	valid_events = @platform.process_sensor.events.where(:starts_at.gte => start_date,
      	     :ends_at.lte => end_date )
      	puts valid_events
      end
    end

  end
end