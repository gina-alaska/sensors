require "csv"

class BarrowImport < DataImport
  def initialize(csvfile, configfile, slug, path)
    # Initialize system
    super(configfile, slug, path)

    # Get sensor information if there is some
    unless configfile.nil?
      sensor_config ||= @config["sensors"] # Read sensors options from config file
      date_config ||= @config["date"]      # Read date information
    else
      @status.update_attributes(status: "Error", message: "I can't find the configuration file", end_time: DateTime.now)
      raise "Configuration file missing! Date information is nessessary!"
    end

    if File.exists?(csvfile)              # Read in the CSV file
      options = {:col_sep => "\t", :headers => true, :converters => :float }
      csv_file = CSV.open( csvfile, 'r', options )
    else
      @status.write_attributes(status: "Error", message: "I can't find the barrow mass balance CSV file \e[31m#{csvfile}\e[0m!", end_time: DateTime.now)
      raise "I can't find the barrow mass balance CSV file \e[31m#{csvfile}\e[0m!"
    end

    csv_file.shift
    headers = csv_file.headers
    sensors = @platform.sensors         # Get current sensors in database

    yearx = dayx = timex = nil					# Initialize date vars
    headers.each_with_index do |source, index|   # Process headers
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
      time = sprintf("%04d", sdata[timex])
      hour = time[0..1] #.slice(0,2)
      min = time[2..3] #.slice(2,2)
      datadate = date_convert( sdata[yearx], 0, sdata[dayx], hour, min, 0, "ordinal" )
      datahash = { :capture_date => datadate }

      sdata.each do |header, data|
        datahash[header] = data
      end

      raw_save( datahash )
      rowindex += 1
    end

    # Finish status reporting
    @status.update_attributes(end_time: DateTime.now,  status: "Finished")

    @platform.save!
  end
end