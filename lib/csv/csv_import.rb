#!/usr/bin/env ruby
# Import sensor csv data file into mongodb
#
require 'csv'

module Sensors
  module Import
    module CsvImport

      class CsvFormat < Import            # Import a CSV file, extends Import class
        attr_accessor :csvopt, :csv_file

        def initialize( csvfile )
          super()

          self.csvopt = @config["csv"]  # Read CSV options from config file

          if File.exists?( csvfile )    # Read in the CSV file
            options = {:col_sep => self.csvopt["delimiter"]}
            self.csv_file = CSV.open( File.open( csvfile ), options )
          else
            puts "I can't find the CSV file \e[31m#{csvfile}\e[0m!"
            exit( -1 )
          end

          if self.csvopt["header"] === true
            headers = self.csv_file.readline 
          else
            headers = self.csvopt["header"]
          end
        end

      end
      
    end
  end
end

