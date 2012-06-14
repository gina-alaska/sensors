class DataImport
  include DataSave
  
	def initialize( configfile )
  	@configfile = configfile
	end

	def platform
		if @platform.nil?
	    @platform = Platform.where(slug: config["platform"]["slug"]).first ||
	      Platform.new
	    if @platform.new_record?
	      @platform.update_attributes!( config["platform"] )
	    end
    end
    @platform
	end

  def sensor_save( sensor_data, source )
  	sensor = platform.sensors.where( source_field: source ).first
    if sensor.nil?
      platform.sensors.push( Sensor.new( sensor_data ) )    # Create sensor
    else
      sensor.update_attributes( sensor_data )               # Update sensor
      sensor.save!
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
  		raise "date_convert: Unknown date type #{type}!"
  	end
  end	

  def config
  	@config ||= ImportConfig.new( @configfile )
  end
end
