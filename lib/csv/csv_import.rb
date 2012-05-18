#!/usr/bin/env ruby
# Import sensor csv data file into mongodb
#
require 'csv'

module Sensors
  module Import
    module CsvImport

      class CsvFormat < Import                # Import a CSV file, extends Import class
        attr_accessor :csvopt, :csv_file, :sensor_config

        def initialize( csvfile )
          super()

          self.csvopt = @config["csv"]        # Read CSV options from config file
          self.sensor_config = @config["sensors"]   # Read sensors options from config file

          if File.exists?( csvfile )          # Read in the CSV file
            options = {:col_sep => self.csvopt["delimiter"], :headers => self.csvopt["header"]}
            self.csv_file = CSV.open( File.open( csvfile ), options )
          else
            puts "I can't find the CSV file \e[31m#{csvfile}\e[0m!"
            exit( -1 )
          end

          if self.csvopt["header"] === true   # Get header field names or get them from config
            self.csv_file.shift
            headers = self.csv_file.headers 
          else
            headers = self.csvopt["header"]
          end

          sensors = @platform.sensors         # Get current sensors in database

          headers.each_with_index do |source, index|   # Process headers
            sensor = @platform.sensors.where( source_field: source ).first
            match = find_sensor(self.sensor_config, source)

            if match.nil?                     # Build sensor data
              sensor_data = {"label" => source,
                             "source_field" => source,
                             "datum" => "data#{index}", 
                             "sensor_metadata" => "no metadata"}
            else
              sensor_data = {"label" => match["label"],
                             "source_field" => source,
                             "datum" => "data#{index}", 
                             "sensor_metadata" => match["metadata"]}
            end

            if sensor.nil?
              @platform.sensors.push( Sensor.new( sensor_data ) )   # Create sensor
            else
              sensor.update_attributes( sensor_data )               # Update sensor
              sensor.save!
            end

            # Import data to database
            until ( sdata = self.csv_file.shift ).nil?
              newdata = RawData.new
              sdata.each_with_index do |data, index|
                newdata.write_attribute( headers[index].to_sym, data )
              end
              newdata.save!
            end
          end
        end

      end

    end
  end
end

