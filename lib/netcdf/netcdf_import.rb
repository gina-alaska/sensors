#!/usr/bin/env ruby
# Import sensor NetCDF data file into MongoDB
#

module SensorImport
  module NetcdfImport

    class TypeNetcdf < Import     # Import a NetCDF file, extends Import class
      attr_accessor :netcdfopt

      def initialize( config_file )
        super( config_file )
      end
    end

    class NetcdfOptions
      attr_accessor :header, :delimiter
    end

  end
end
