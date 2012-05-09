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

include Methadone::Main         # Options parsing
include Methadone::CLILogging   # Debug/logging
include SensorImport

main do |csv_file, data_config|
  # Initialize sensor import
  import = TypeCsv.new( data_config, csv_file )

  # Check for csv file and read it in
  if !File.exists?(csv_file)
    error "I can't find the CSV file \e[31m#{csv_file}\e[0m!"
  else
    csvdata = CSV.read(csv_file, {:col_sep => delimiter})
  end

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

description "Import mass balance csv file into a MongoDB database."

arg "CSV_filename"
arg "Database_configuration_file"

go!
