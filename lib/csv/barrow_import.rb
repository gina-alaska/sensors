#!/usr/bin/env ruby
# Import sensor csv data file into mongodb
#
require 'csv'

module Sensors
  module Import
    module CsvImport

      class BarrowFormat < Import         # Import a barrow CSV file, extends Import class
        attr_accessor :csvopt, :csv_file, :sensor_config, :date_config

        def initialize( csvfile )
          super()

          self.csvopt = @config["csv"]              # Read CSV options from config file
          self.sensor_config = @config["sensors"]   # Read sensors options from config file
          self.date_config = @config["date"]        # Read date options from config file

          if File.exists?( csvfile )          # Read in the CSV file
            options = {:col_sep => self.csvopt["delimiter"], :headers => self.csvopt["header"],
                  :converters => :float }
            self.csv_file = CSV.open( csvfile, 'r', options )
          else
            puts "I can't find the CSV file \e[31m#{csvfile}\e[0m!"
            exit( -1 )
          end

          self.csv_file.shift
          headers = self.csv_file.headers
          sensors = @platform.sensors         # Get current sensors in database

          @yearx = @dayx = @timex = nil
          headers.each_with_index do |source, index|   # Process headers
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

            sensor = @platform.sensors.where( source_field: source ).first
            if sensor.nil?
              @platform.sensors.push( Sensor.new( sensor_data ) )   # Create sensor
            else
              sensor.update_attributes( sensor_data )               # Update sensor
              sensor.save!
            end

            # Find date field indexes
            @yearx = index if self.date_config["year"] == source
            @dayx = index if self.date_config["day"] == source
            @timex = index if self.date_config["time"] == source
          end

          # Import CSV file rows to database
          rowindex = 1
          self.csv_file.each do |sdata|
            time = sprintf("%04d", sdata[@timex])
            hour = time[0..1] #.slice(0,2)
            min = time[2..3] #.slice(2,2)
            datadate = date_convert( sdata[@yearx], 0, sdata[@dayx], hour,
                          min, 0, "ordinal" )
            datahash = { :capture_date => datadate }

            sdata.each do |header, data|
              datahash[header.to_sym] = data
            end

            newdata = RawData.new
            newdata.write_attributes( datahash )
            begin
              newdata.save!
            rescue
              puts "Data insert failed date validation at row #{rowindex}"
              puts datahash
            end
            rowindex += 1
          end

        end

      end

    end
  end
end

