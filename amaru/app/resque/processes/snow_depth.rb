module Processes
  # Correct snow depth
  def snow_depth(opts) #command, input, sensors)
    command= opts[:cmd]
    input = opts[:input]

    sensor_height = command.param_one.to_f

    data = input.shift
    if data == @platform.no_data_value
      result = data
    else
      result = sensor_height - data.to_f
    end

    Array.wrap(result)
  end
end