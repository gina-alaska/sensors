#!/usr/bin/env ruby
# Import sensor data into GINA sensor repository.
#

module SensorImport
  autoload :CsvImport,		'csv/csv_import'
  autoload :NetcdfImport,	'csv/netcdf_import'

  class Import			# Base import class
    attr_accessor :database
    def initialize( config_file )
      if File.exists?( config_file )
        @config = YAML.load_file(config_file)
      else
        error "I can't find the configuration file \e[31m#{@config_file}\e[0m!"
      end
      
      if @config["database"].nil?
        error "There is no database section in the configuration file!"
      else
        self.database = Database.new( @config["database"] )
      end
    end
  end

  class Database		# Set up connection to mongodb database
    attr_accessor :host, :name, :platform, :raw_data, :final_data, :dbconnect
    def initialize( database )
      self.host ||= database["host"]
      self.name ||= database["name"]
      self.platform ||= database["platform_coll"]
      self.raw_data ||= database["raw_data_coll"]
      self.final_data ||= database["final_data_coll"]
    end

    def connect			# Connect to database
      if self.host.nil? && self.name.nil?
        error "The host name and database name, \e[31mmust\e[0m be defined in
           the database section of the configuration file!"
      else
        @connection = Mongo::Connection.new( self.host )
        self.dbconnect = @connection.db( self.name )
      end
    end
  end

  class Platform
    attr_accessor :name, :agency, :metadata, :geo_loc, :license, :permissions
  end

  class Sensor
    attr_accessor :sensors
  end

  class Process
    attr_accessor :processes
  end

  class Alert
    attr_accessor :alerts
  end
end
