module Processes
  # Adjust ice thicknes
  def ice_thickness(opts)
    command = opts[:cmd]
    input = opts[:input]
    sensor_height = command.param_one.to_f
    water_sensor = command.param_two
    snow_depth = command.param_three
    capture_date = opts[:data_row].capture_date

    if opts[:processed_data].send(snow_depth.to_sym).nil? or opts[:processed_data].send(snow_depth.to_sym) == @platform.no_data_value
      snow_data = 0.0
    else
      snow_data = opts[:processed_data].send(snow_depth.to_sym)
    end

    data = input.shift
    if data == @platform.no_data_value
      result = data
    else
      ss_correction = sound_speed(opts[:data_row].send(water_sensor.to_sym))

      if snow_data.to_f < 0.0
        result = sensor_height - (ss_correction * data.to_f) + snow_data.to_f
      else
        result = sensor_height - (ss_correction * data.to_f)
      end
    end

    Array.wrap(result)
  end
end