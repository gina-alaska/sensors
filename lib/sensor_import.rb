#!/usr/bin/env ruby
# Talk to sensor data in the GINA sensor repository.
#

module Sensor 
  autoload :CsvImport,		'csv/csv_import'
  autoload :NetcdfImport,	'csv/netcdf_import'

  class Import		  	# Base import class
    attr_accessor :database, :platform
    def initialize( config_file )
      if File.exists?( config_file )
        @config = YAML.load_file(config_file)
      else
        error "I can't find the configuration file \e[31m#{@config_file}\e[0m!"
      end

      self.database = do_section( Database, "database" )
      self.platform = do_section( Platform, "platform" )
    end

    protected

    def do_section(klass, section)
      if @config[section].nil?
        error "There is no #{section} in the configuration file!"
      else
        klass.new( @config[section] )
      end
    end
  end

  class Database  		# Set up connection to mongodb database
    attr_accessor :host, :name, :platform, :raw_data, :final_data, :mongo_connect, :dbconnect,
          :platform_coll, :raw_coll, :final_coll

    def initialize( database )
      self.host ||= database["host"]
      self.name ||= database["name"]
      self.platform ||= database["platform_coll"]
      self.raw_data ||= database["raw_data_coll"]
      self.final_data ||= database["final_data_coll"]
    end

    def connect	  		# Connect to database
      if self.host.nil? && self.name.nil?
        error "The host name and database name, \e[31mmust\e[0m be defined in
           the database section of the configuration file!"
      else
        connection = Mongo::Connection.new( self.host )
        self.mongo_connect = connection
        self.dbconnect = connection.db( self.name )
        self.platform_coll = self.dbconnect[ self.platform ]
        self.raw_coll = self.dbconnect[ self.raw_data ]
        self.final_coll = self.dbconnect[ self.final_data ]
      end
    end
  end

  class Platform
    attr_accessor :name, :agency, :metadata, :geo_loc, :license, :permissions

    def initialize( platform_config )
      self.name ||= platform_config["name"]
      self.agency ||= platform_config["agency"]
      self.metadata ||= platform_config["metadata"]
      self.geo_loc ||= platform_config["geo_loc"]
      self.license ||= platform_config["license"]
      self.permissions ||= platform_config["permissions"]
    end
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
