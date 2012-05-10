#!/usr/bin/env ruby
# Import sensor csv data file into mongodb
#

module Sensor
  module CsvImport

    class TypeCsv < Import            # Import a CSV file, extends Import class
      attr_accessor :csvopt, :csv_file

      def initialize( config_file, csvfile )
        super( config_file )          # Do base class setup (database, read config file, etc)
        self.csvopt = do_section CsvOptions, "csv"  # Read in CSV options from config file

        self.database.connect         # Connect to database

        if File.exists?( csvfile )    # Read in the CSV file
          self.csv_file = CSV.read( csvfile )
        else
          error "I can't find the CSV file \e[31m#{csvfile}\e[0m!"
        end

        platform_ingest
      end

      def platform_ingest
        colls = self.database.dbconnect.collection_names
        puts colls.include?( self.database.platform )
      end
    end

    class CsvOptions                  # CSV import options
      attr_accessor :header, :delimiter

      def initialize( options )
        self.header ||= options["header"]
        self.delimiter ||= options["delimiter"]
      end
    end
  end
end

