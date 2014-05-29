require "csv"

class RestImport < DataImport
  def initialize(slug, token, data)
    # Initialize system
    super(nil, nil, slug, nil, token)
    @data = data
  end

  def import
    save_zone = Time.zone
    Time.zone = "UTC"
    options = {:col_sep => ",", :headers => true}
    csv_data = CSV.parse(@data, options)

    sensors = @platform.sensors.all
    headers = csv_data.headers

    headers.each do |source|
      unless source == "date"
        sensor_data = {"label" => source, "source_field" => source, "sensor_metadata" => "No Metadata"}
        sensor_save(sensor_data, source)
      end
    end

    start_time = Time.zone.parse(csv_data[0]["date"])
    csv_data.each do |sdata|
      datahash = { :capture_date => Time.zone.parse(sdata["date"]) }

      sdata.each do |header, data|
        datahash[header] = data
      end
      datahash.delete("date")

      raw_save(datahash)
    end

    @platform.save

    # Finish status reporting
    @status.update_attributes(end_time: Time.zone.now,  status: "Finished")

    # Start import data processing
    @platform.async_process_event_single(start_time, nil) unless @platform.groups.size == 0
    Time.zone = save_zone
  end
end