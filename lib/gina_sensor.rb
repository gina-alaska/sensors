#!/usr/bin/env ruby
# Talk to sensor data in the GINA sensor repository.
#
require 'singleton'
require 'yaml'
require 'mongoid'

module Sensors
  autoload :Import, 'sensor_import'
  autoload :Process, 'process.rb'
  autoload :Platform, "sensors/platform.rb"
  autoload :Sensor, "sensors/sensor.rb"
  autoload :RawDatum, "sensors/raw_datum.rb"
  autoload :ProcessedDatum, "sensors/processed_datum.rb"
  autoload :ProcessSensor, "sensors/process_sensor.rb"
  autoload :Event, "sensors/event.rb"

  class Config	          # Read in configuration file
    include Singleton
    attr_accessor :database

    def load( config_file )
      if File.exists?( config_file )
        @config = YAML.load_file(config_file)
      else
        puts "I can't find the configuration file \e[31m#{@config_file}\e[0m!"
        exit( -1 )
      end

      self.database = do_section( Database, "database" )
      self.database.connect
    end

    def [](section)
      if @config[section].nil?
        puts "There is no \e[31m#{section}\e[0m! in the configuration file!"
        exit( -1 )
      else
        @config[section]
      end
    end

    def do_section(klass, section)
      klass.new( self[section] )
    end
  end

  class Database  		# Set up connection to mongodb database via mongoid

    def initialize( database )
      @name = database["name"]
      @port = database["port"]
      @host = database["host"]
      @year = database["year"]
    end

    def self.year
      @year
    end

    def connect	  		# Connect to database
      if @host.nil? || @name.nil? || @port.nil?
        puts "The host name, database name, and port number \e[31mmust\e[0m be defined in
           the database section of the configuration file!"
        exit( -1 )
      else
        Mongoid.configure do |config|
          name = @name
          host = @host
          port = @port
          allow_dynamic_fields = true

          config.master = Mongo::Connection.new.db( @name )
        end
      end
    end
  end

  class Alert
    attr_accessor :alerts
  end
end
