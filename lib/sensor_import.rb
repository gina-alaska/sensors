#!/usr/bin/env ruby
# 
# GINA Sensor Import Module
#

module Sensors
  module Import
    autoload :CsvImport,		'csv/barrow_import'
#    autoload :NetcdfImport,	'netcdf/netcdf_import'

    class Import
    	attr_accessor :platform

    	def initialize
    	  @config = Sensors::Config.instance
        @platform = Platform.first || Platform.new
        @platform.update_attributes( @config["platform"] )
        begin
          @platform.save!
        rescue
        	puts "Platform insertion/update error!"
        	puts @platform.errors.messages
        	exit( -1 )
        end
      end

      def find_sensor( sensors, source )
        sensors.each do |sensor|
          return sensor if sensor["field"] == source
        end
        return nil
      end 

      def date_convert( year, month, day, hour, min, sec, type )
      	case type
      	when "ordinal"
      		return DateTime.ordinal( year.to_i, day.to_i, hour.to_i, min.to_i ).iso8601
      	when "julian"
      		return DateTime.jd( day.to_i, hour.to_i, min.to_i ).iso8601
      	else
      		puts "Unknown date type #{type}! Please correct configuration file."
      		exit( -1 )
      	end
      end
      
    end

  end
end