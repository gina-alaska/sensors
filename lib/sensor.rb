#!/usr/bin/env ruby
# Talk to sensor data in the GINA sensor repository.
#
require 'singleton'
#require 'json'
require 'yaml'
require 'mongoid'

module Sensors
  autoload :Import, 'sensor_import'

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
    attr_accessor :host, :name, :port, :raw_data, :final_data, :dbconnect

    def initialize( database )
      self.host ||= database["host"]
      self.name ||= database["name"]
      self.port ||= database["port"]
      self.raw_data ||= database["raw_data_coll"]
      self.final_data ||= database["final_data_coll"]
    end

    def connect	  		# Connect to database
      if self.host.nil? || self.name.nil? || self.port.nil?
        puts "The host name, database name, and port number \e[31mmust\e[0m be defined in
           the database section of the configuration file!"
        exit( -1 )
      else
        Mongoid.configure do |config|
          name = self.name
          host = self.host
          port = self.port
          config.master = Mongo::Connection.new.db( self.name )
        end
      end
    end
  end

  class Platform
    include Mongoid::Document

    field :name,                type: String
    field :platform_metadata,   type: String
    field :geo_location,        type: String
    field :license,             type: String
    field :permissions,         type: String
    field :agency,              type: String
    field :authority,           type: String

    validates_presence_of :name
    validates_presence_of :platform_metadata
    validates_presence_of :geo_location
    validates_presence_of :license
    validates_presence_of :permissions
    validates_presence_of :agency
    validates_presence_of :authority

    validates_uniqueness_of :name

    embeds_many :header
  end

  class Header
    include Mongoid::Document

    field :label,               type: String
    field :source_field,        type: String
    field :datum,               type: String
    field :sensor_metadata,     type: String

    validates_presence_of :label
    validates_presence_of :source_field
    validates_presence_of :datum
    validates_presence_of :sensor_metadata

    validates_uniqueness_of :source_field

    embedded_in :platform
  end

  class Process
    attr_accessor :processes
  end

  class Alert
    attr_accessor :alerts
  end
end
