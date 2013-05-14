module Processes
  # Adjust water depth
  def water_depth(opts)
    command = opts[:cmd]
    sensor_height = command.param_one.to_f
    water_sensor = command.param_two
    input = opts[:input]

    data = input.shift
    if data == @platform.no_data_value
      result = data
    else
      ss_correction = sound_speed(opts[:data_row].send(water_sensor.to_sym))
      result = sensor_height + (ss_correction * data.to_f)
    end

    Array.wrap(result)
  end
end