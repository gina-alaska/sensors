class DataImport
  
	def initialize( configfile, slug, path )
    # Find or initialize the platform
    @platform = Platform.where(slug: slug).first || Platform.new
    if @platform.new_record?
      @platform.update_attributes!( slug: slug )
    end

    # Initialize the status system
    @status = @platform.status.build(system: "import", message: "Importing data for platform #{slug}.", status: "Running", start_time: DateTime.now)
    @status.save

    # Read in configuration file if available
    unless configfile == "false"
      if File.exists?( File.join(path, configfile) )
        @config = YAML.load_file(File.join(path, configfile))
      else
        @status.update_attributes(status: "Error", message: "I can't find the configuration file #{path+"/"+configfile}!", end_time: DateTime.now)
        raise "I can't find the configuration file \e[31m#{path+"/"+configfile}\e[0m!"
      end
    end
	end

  def [](section)
    if @config[section].nil?
      @status.update_attributes(status: "Error", message: "There is no #{section} in the configuration file!", end_time: DateTime.now)
      raise "There is no \e[31m#{section}\e[0m in the configuration file!"
    else
      @config[section]
    end
  end

  def sensor_save( sensor_data, source )
  	sensor = @platform.sensors.where( source_field: source ).first
    if sensor.nil?
      @platform.sensors.push( Sensor.new( sensor_data ) )    # Create sensor
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
      @status.update_attributes(status: "Error", message: "date_convert: Unknown date type #{type}!", end_time: DateTime.now)
  		raise "date_convert: Unknown date type \e[31m#{type}\e[0m!"
  	end
  end	

  def raw_save( datahash )
    newdata = RawDatum.create(datahash)

    if newdata.valid?
      @platform.raw_data << newdata
    else
      @status.update_attributes(status: "Error", message: "Raw data insert failed MongoDB validation!", end_time: DateTime.now)
      raise "raw data insert failed MongoDB validation:\n #{datahash}"
    end
  end

  def processed_save( datahash )
    newdata = ProcessedDatum.create(datahash)

    if newdata.valid?
      @platform.processed_data << newdata
    else
      @status.update_attributes(status: "Error", message: "Processed data insert failed MongoDB validation!", end_time: DateTime.now)
      raise "processed data insert failed MongoDB validation:\n #{datahash}"
    end
  end
end
