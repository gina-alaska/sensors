module Processes
  # Adjust ice thicknes
  def ice_thickness_therm(opts)
    command = opts[:cmd]
    input = opts[:input]
    sensor_height = command.param_one.to_f
    thermistors = command.param_two.split(",")

    capture_date = opts[:data_row].capture_date
    found_therm = ""
    result = 0.0

    thermistors.reverse_each do |thermistor|
      if opts[:raw_data].send(thermistor.to_sym).to_f <= -2.5
        found_therm = thermistor
        break
      end
    end

    if found_therm != ""
      sensor_depth = found_therm.split("(")[1].chop.to_f
      result = (sensor_depth / 10.0) - sensor_height + 0.05
    else
      result = @platform.no_data_value
    end

    Array.wrap(result)
  end
end