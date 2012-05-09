#!/usr/bin/env ruby
# Import sensor csv data file into mongodb
#

module SensorImport
  module CsvImport

    class TypeCsv < Import        # Import a CSV file, extends Import class
      attr_accessor :csvopt, :csv_file

      def initialize( config_file, csvfile )
        super( config_file )
        if @config["csv"].nil?
          error "The CSV section of the configuration file is missing!"
        else
          self.csvopt ||= CsvOptions.new( @config["csv"] )
          self.csv_file ||= csvfile
        end
      end
    end

    class CsvOptions              # CSV import options
      attr_accessor :header, :delimiter

      def initialize( options )
        self.header ||= options["header"]
        self.delimiter ||= options["delimiter"]
      end
    end

  end
end

