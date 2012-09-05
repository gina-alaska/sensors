module Processes
  # Copy a raw data field to a new field in the processed data collection.
  def copy(processed_field, sensors, process)
    sensor = sensors.first
    puts "Copying raw data #{sensor} to processed data #{processed_field}."
    puts "start - #{process.starts_at} end - #{process.ends_at}"
  statats
    raw = @platform.raw_data.captured_between(process.starts_at, process.ends_at).only(:capture_date, sensor.to_sym)
    raw.each do |raw_row|
      processed = @platform.processed_data.find_or_create_by(
          capture_date: raw_row.capture_date)
      processed.update_attribute(processed_field, raw_row[sensor])
    end
    puts "End Copy"
  end
end