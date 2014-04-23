require "csv"

class BarrowImport < DataImport
  def initialize(csvfile, configfile, group, slug, path, token)
    # Initialize system
    super(configfile, group, slug, path, token)
    save_zone = Time.zone
    Time.zone = "UTC"

    # Get sensor information if there is some
    unless configfile.nil?
      sensor_config ||= @config["sensors"] # Read sensors options from config file
      date_config ||= @config["date"]      # Read date information
    else
      @status.update_attributes(status: "Error", message: "I can't find the configuration file", end_time: Time.zone.now)
      raise "Configuration file missing! Date information is nessessary!"
    end

    if File.exists?(csvfile)              # Read in the CSV file
      case date_config["version"]
      when "1"
        options = {:col_sep => "\t", :headers => true, :converters => :float }
      when "2"
        options = {:col_sep => ",", :headers => true}
      end
      csv_file = CSV.open( csvfile, 'r', options )
    else
      @status.write_attributes(status: "Error", message: "I can't find the barrow mass balance CSV file \e[31m#{csvfile}\e[0m!", end_time: Time.zone.now)
      raise "I can't find the barrow mass balance CSV file \e[31m#{csvfile}\e[0m!"
    end

    csv_file.shift
    headers = csv_file.headers
    sensors = @platform.sensors         # Get current sensors in database

    yearx = dayx = timex = nil	      	# Initialize date vars
    headers.each_with_index do |source, index|        # Process headers
      match = @config["sensors"].nil? ? nil : find_sensor( sensor_config, source )
      if match.nil?                     # Build sensor data
        sensor_data = {"label" => source, "source_field" => source, "sensor_metadata" => "no metadata"}
      else
        sensor_data = {"label" => match["label"], "source_field" => source, "sensor_metadata" => match["metadata"]}
      end

      sensor_save( sensor_data, source )

      # Find date field indexes
      yearx = index if date_config["year"] == source
      dayx = index if date_config["day"] == source
      timex = index if date_config["time"] == source
    end

    # Import CSV file rows to database
    rowindex = 1
    csv_file.each do |sdata|
      if date_config["version"] == "1"
        time = sprintf("%04d", sdata[timex])
        hour = time[0..1]
        min = time[2..3]
      end

      case date_config["version"]
      when "1"
        datadate = date_convert( sdata[yearx], 0, sdata[dayx], hour, min, 0, "ordinal" )
      when "2"
        datadate = Time.strptime(sdata[0], "%Y-%m-%d %H:%M:%S")
        #datadate = Time.zone.parse(sdata[0])
      else
        raise "Unknown import file version!"
      end

      datahash = { :capture_date => datadate }

      sdata.each do |header, data|
        datahash[header] = data
      end

      raw_save( datahash )
      rowindex += 1
    end

    # Finish status reporting
    @status.update_attributes(end_time: Time.zone.now,  status: "Finished")

    @platform.save!
    Time.zone = save_zone
  end
end