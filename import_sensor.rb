#!/usr/bin/env ruby
# Import sensor data from a ingest data file into a database.
#

$: << File.expand_path( "lib/", File.dirname( __FILE__ ) )

require 'sensor.rb'
require 'trollop'

include Sensors
include Sensors::Import

opts = Trollop::options do
  banner "Import sensor data into the GINA sensor MongoDB database"
  opt :data_config, "Database configuration file", {:type => String, :required => true}
  opt :ingest_file, "Ingest data filename", {:type => String, :required => true}
  opt :file_type, "Ingest data file format (csv,netcdf)", {:type => String, :required => true}
end

# Read in sensor configuration file
Sensors::Config.instance.load( opts[:data_config] )

# Import sensor data
case opts[:file_type]
  when "csv"
    import = CsvImport::CsvFormat.new( opts[:ingest_file] )
  else
    Trollop::die "Unknown ingest file format \e[31m#{opts[:file_type]}\e[0m"
end
