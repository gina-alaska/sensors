module Processes
  # Calculate snow depth and put it into a new processed data field.
  def snow_depth(processed_field, sensors, process, start_time, source_data)
    sensor = sensors.first
    sensor_height = process.window.to_f

    if start_time.nil?
      start_date = process.starts_at
    else
      start_date = Time.parse(start_time)
    end
    end_date = process.ends_at

    puts "Calculating Snow Depth on raw data #{sensor} to processed data
        #{processed_field}."
    puts "start - #{start_date} end - #{process.ends_at}"

    if process.index == 0
      raw = source_data.captured_between(start_date, end_date).only(:capture_date, sensor.to_sym)
    else
      raw = source_data.captured_between(start_date, end_date).only(:capture_date, processed_field.to_sym)
    end

    raw.each do |row|
      if process.index == 0
        rawdata = row[sensor.to_sym] == @platform.no_data_value ? nil : row[sensor.to_sym].to_f
      else
        rawdata = row[processed_field.to_sym] == @platform.no_data_value ? nil : row[processed_field.to_sym].to_f
      end

      processed = process.output_data.where(capture_date: row.capture_date).first
      if processed.nil?
        processed = process.output_data.create(capture_date: row.capture_date)
      end
      #processed.command = process

      if rawdata == @platform.no_data_value or rawdata.nil?
        processed.update_attribute(processed_field, rawdata)
      else
        processed.update_attribute(processed_field, sensor_height - rawdata)
      end
    end

    puts "End Processing Snow Depth"
  end
end