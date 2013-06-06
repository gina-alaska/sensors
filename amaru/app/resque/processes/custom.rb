module Processes
  # Gather data and send it and the users custom code to stats package for 
  # processing.
  def custom(processed_field, sensors, process, start_time, command_index)
    sensor = sensors.first
    value, units = process.window.split(".")
    start_date = process.starts_at
    end_date = process.ends_at
    custom_code = process.command_text

    myr = RinRuby.new(false)

    puts "Processing custom code on raw data #{sensor} output to processed data
        #{processed_field}."
    puts "start - #{start_date} end - #{process.ends_at}"

    if command_index == 0
      raw = @platform.raw_data.captured_between(start_date, end_date).only(:capture_date, sensor.to_sym)
    else
      raw = @platform.processed_data.captured_between(start_date, end_date).only(:capture_date, processed_field.to_sym)
    end

    # Build array to send to R, convert all no data values to nil.
    rdata = []
    raw.each do |value|
      rawdata = value[sensor.to_sym].to_f == @platform.no_data_value.to_f ? nil : value[sensor.to_sym]
      rdata.push(rawdata)
    end

    # Do stat processing
    myr.data = rdata.compact
    myr.eval(custom_code)

    # Push processed data to processed_data collection.
    raw.each_with_index do |row, index|
      processed = @group.processed_data.find_or_create_by(
            capture_date: row.capture_date)
      processed.platform = @platform
      processed.update_attribute(processed_field, myr.pdata[index])
    end

    myr.quit
    puts "End custom process"
  end
end
