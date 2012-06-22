module PlatformsHelper
  def hc_sensors_select(sensors)
    shash = Hash.new
    sensors.each do |sensor|
      shash["#{sensor["source_field"]}"] = sensor["source_field"]
    end
    options_for_select(shash)
  end

  def hc_proc_select(fields)
    shash = Hash.new
    fields.each do |proc|
      shash["#{proc["name"]}"] = proc["name"]
    end
    options_for_select(shash)
  end
end
