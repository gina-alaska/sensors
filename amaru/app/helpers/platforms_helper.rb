module PlatformsHelper
  def hc_sensors_select(sensors, selected)
    shash = Hash.new
    sensors.each do |sensor|
      shash[sensor["source_field"]] = sensor["source_field"]
    end
    options_for_select(shash, selected)
  end

  def hc_proc_select(fields, selected)
    shash = Hash.new
    fields.each do |proc|
      shash[proc["name"]] = proc["name"]
    end
    options_for_select(shash, selected)
  end
end
