module Processes
  # Cull values and replace them with the no_data_value
  def cull(opts)
    command= opts[:cmd]
    input = opts[:input]

    cull_operand = command.param_one.to_i
    cull_value = command.param_two.to_f

    data = input.shift
    result = data

    case cull_operand
    when 1
      result = @platform.no_data_value if data.to_f == cull_value
    when 2
      result = @platform.no_data_value if data.to_f < cull_value
    when 3
      result = @platform.no_data_value if data.to_f > cull_value
    when 4
      result = @platform.no_data_value if data.to_f <= cull_value
    when 5
      result = @platform.no_data_value if data.to_f >= cull_value
    end

    Array.wrap(result)
  end
end