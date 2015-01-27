module Processes
  # Calculate Julian decimal day
  def julian(opts)
    command= opts[:cmd]
    input = opts[:input]

    hour_sensor   = command.param_one
    minute_sensor = command.param_two

    data = input.shift.to_i

    result = data + (((opts[:data_row].send(hour_sensor.to_sym).to_i * 60.0) + opts[:data_row].send(minute_sensor.to_sym).to_i)/ 1440.0)

    Array.wrap(result)
  end
end