module Processes
  # Calculate Julian decimal day
  def julian(opts)
    command= opts[:cmd]
    input = opts[:input]

    hour_sensor   = command.param_one
    minute_sensor = command.param_two

    data = input.shift

    result = data + (((opts[:data_row].send(hour_sensor.to_sym) * 60) + opts[:data_row].send(minute_sensor.to_sym))/ 1440)

    Array.wrap(result)
  end
end