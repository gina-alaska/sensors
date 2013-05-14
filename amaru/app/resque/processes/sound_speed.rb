module Processes
  def sound_speed(temp)
    (1449 + 4.6 * temp.to_f) / 1500
  end
end