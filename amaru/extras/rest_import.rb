require "csv"

class RestImport < DataImport
  def initialize(slug, data)
    # Initialize system
    super(nil, nil, slug, nil)
    @data = data
  end

  def import
    options = {:col_sep => ",", :headers => true, :converters => :float}
    csv_data = CSV.parse(@data, options)

    sensors = @platform.sensors.all
    headers = csv_data.headers

    headers.each do |source|
      unless source == "date"
        sensor_data = {"label" => source, "source_field" => source, "sensor_metadata" => "No Metadata"}
        sensor_save(sensor_data, source)
      end
    end


    csv_data.each do |sdata|
      datahash = { :capture_date => DateTime.parse(sdata["date"]).iso8601 }

      sdata.each do |header, data|
        datahash[header] = data
      end
      datahash.delete("date")

      raw_save(datahash)
    end

    # Finish status reporting
    @status.update_attributes(end_time: DateTime.now,  status: "Finished")

    @platform.save
  end
end