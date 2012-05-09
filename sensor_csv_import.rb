#!/usr/bin/env ruby
# Import sensor data from a csv file into a database.
# Currently the script supports the mongo database.
#

$: << File.expand_path( "lib/", File.dirname( __FILE__ ) )

require 'mongo'
require 'csv'
require 'methadone'
require 'yaml'
require 'sensor_import.rb'

include Methadone::Main           # Options parsing
include Methadone::CLILogging     # Debug/logging
include SensorImport              # GINA sensor data import
include SensorImport::CsvImport   # GINA sensor data import csv module

main do |data_config, csv_file|
  # Initialize sensor import
  import = TypeCsv.new( data_config, csv_file )

puts import.csvopt.header
exit
  # Connect to database and read in csv file
  connection = Mongo::Connection.new(dbhost)
  @database = connection.db(dbname)

exit
  # Ingest CSV data into database
  @header = csvdata.shift
  csvdata.each do |row|
    datarr = row[0].split("\t")
    dbdata = ""
    dbcommand = "INSERT INTO mass_balance_data (created_at, updated_at"
    datarr.each_with_index do |field, cnt|
      dbcommand += ", data#{cnt}"
      dbdata += ", '#{field}'"
    end
    dbcommand += ") VALUES (localtimestamp, localtimestamp"+dbdata+" );"
    response = @database.exec(dbcommand)
  end

end

description "Import sensor data csv file into a MongoDB database."

arg "Database_configuration_file"
arg "CSV_filename"

go!
