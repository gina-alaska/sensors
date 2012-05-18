#!/usr/bin/env ruby
# 
# GINA Sensor Import Module
#

module Sensors
  module Import
    autoload :CsvImport,		'csv/csv_import'
    autoload :NetcdfImport,	'netcdf/netcdf_import'

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
    end

  end
end