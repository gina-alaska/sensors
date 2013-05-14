module Processes
  # Adjust ice thicknes
  def ice_thickness(opts)
    command = opts[:cmd]
    input = opts[:input]
    sensor_height = command.param_one.to_f
    water_sensor = command.param_two
    snow_depth = command.param_three
    capture_date = opts[:data_row].capture_date

    snow_data = opts[:processed_data].send(snow_depth.to_sym)
    if snow_data == @platform.no_data_value or snow_data.nil?
      snow_data = 0
    end

    data = input.shift
    if data == @platform.no_data_value
      result = data
    else
      ss_correction = sound_speed(opts[:data_row].send(water_sensor.to_sym))
      snow_data = @group.processed_data.where(capture_date: capture_date).first[snow_depth.to_sym]

      if snow_data.to_f < 0.0
        result = sensor_height + (ss_correction * data.to_f) + snow_data.to_f
      else
        result = sensor_height + (ss_correction * data.to_f)
      end
    end

    Array.wrap(result)
  end
end