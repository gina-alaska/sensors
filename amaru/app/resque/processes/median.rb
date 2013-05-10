module Processes
  # Using R, calculate the median filter on the data.
  def median(processed_field, sensors, process, start_time, source_data)
    sensor = sensors.first
    value, units = process.param_one.split(".")
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

    puts "****** class = #{process.index.class} *******"
    if process.index.to_i == 0
      raw = source_data.captured_between(start_date, end_date).only(:capture_date, sensor.to_sym)
    else
      raw = source_data.captured_between(start_date, end_date).only(:capture_date, processed_field.to_sym)
    end

    raw.each do |row|
      if process.index.to_i == 0
        data = source_data.captured_between(row.capture_date - window, row.capture_date + window).only(sensor.to_sym)
      else
        data = source_data.captured_between(row.capture_date - window, row.capture_date + window).only(processed_field.to_sym)
      end

      # Build array to send to R, convert all no data values to nil.
      rdata = []
      data.each do |value|
        if process.index.to_i == 0
          rawdata = value[sensor.to_sym] == @platform.no_data_value ? nil : value[sensor.to_sym].to_f
        else
          rawdata = value[processed_field.to_sym] == @platform.no_data_value ? nil : value[processed_field.to_sym].to_f
        end
        rdata.push(rawdata)
      end

      # Do R mean processing
      myr.data = rdata.compact
      myr.eval <<-EOF
        mdata <- median(data)
      EOF

      # Push processed data to processed_data collection.
      processed = process.output_data.where(capture_date: row.capture_date).first
      if processed.nil?
        processed = process.output_data.create(capture_date: row.capture_date)
      end
      #processed.command = process
      processed.update_attribute(processed_field, myr.mdata)
    end

    myr.quit
    puts "End Median Filter"
  end
end