module Processes
  # Using R, calculate the median filter on the data.
  def median(processed_field, sensors, process, start_time)
    sensor = sensors.first
    value, units = process.window.split(".")
    window = value.to_i.send(units.to_sym)
    if start_time.nil?
      start_date = process.starts_at.nil? ? nil : process.starts_at - window
    else
      start_date = Time.parse(start_time) - window - window
    end
    end_date = process.ends_at.nil? ? nil : process.ends_at + window

    myr = RinRuby.new(false)

    puts "calculating median filter on raw data #{sensor} to proc data #{processed_field}."
    puts "start - #{start_date} end - #{process.ends_at}"
    raw = @platform.raw_data.captured_between(start_date, end_date).only(:capture_date, sensor.to_sym)

    raw.each do |row|
      data = @platform.raw_data.captured_between(row.capture_date - window, row.capture_date + window).only(sensor.to_sym)

      # Build array to send to R, convert all no data values to nil.
      rdata = []
      data.each do |value|
        rawdata = value[sensor.to_sym].to_f == @platform.no_data_value.to_f ? nil : value[sensor.to_sym]
        rdata.push(rawdata)
      end

      # Do R mean processing
      myr.data = rdata.compact
      myr.eval <<-EOF
        mdata <- median(data)
      EOF

      # Push processed data to processed_data collection.
      processed = @group.processed_data.find_or_create_by(
              capture_date: row.capture_date)
      processed.platform = @platform
      processed.update_attribute(processed_field, myr.mdata)
    end

    myr.quit
    puts "End Median Filter"
  end
end