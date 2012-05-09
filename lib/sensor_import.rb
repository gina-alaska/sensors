# Import sensor data into GINA sensor repository.
#

module SensorImport
  class Import			# Base import class
    attr_accessor :database
    def initialize( config_file )
      if File.exists?( config_file )
        config = YAML.load_file(config_file)
      else
        error "I can't find the configuration file \e[31m#{config_file}\e[0m!"
      end
      if config["database"].nil?
        error "There is no database section in the configuration file!"
      else
        self.database = Database.new( config["database"] )
      end
    end
  end

  class TypeCsv < Import	# Import a CSV file, extends Import class
    attr_accessor :csvopt, :csv_file
    def initialize( config_file, csvfile )
      super( config_file )
      self.csvopt ||= CsvOptions.new( config_file["csv"] )
      self.csv_file ||= csvfile
    end
  end

  class TypeNetcdf < Import	# Import a NetCDF file, extends Import class
    attr_accessor :netcdfopt
    def initialize( config_file )
      super( config_file )
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

  class CsvOptions
    attr_accessor :header, :delimiter
    def initialize( options )
      self.header ||= options["header"]
      self.delimiter ||= options["delimiter"]
    end
  end

  class NetcdfOptions
    attr_accessor :header, :delimiter
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
