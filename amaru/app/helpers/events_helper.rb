module EventsHelper
	def datepicker_format(date)
		date.try(:utc).try(:strftime, "%F %T%z")
	end

	def event_commands(selected)
		options_for_select([["Custom","custom"],["Copy","copy"], ["Snow Depth", "snow_depth"], ["Water Depth", "water_depth"], ["Ice Thickness", "ice_thickness"], ["Thermistor Ice Thickness", "ice_thickness_therm"], ["Cull", "cull"], ["Julian Decimal Day", "julian"]], "#{selected}")
	end

	def sensors_select(sensors, selected)
		shash = Hash.new
		sensors.each do |sensor|
			shash["#{sensor}"] = sensor
		end
    options_for_select(shash, selected)
	end

	def field_label(fields)
		label = ""
		fields.each do |field|
			label += "<span class=\"label label-info\">#{field}</span> "
		end
		return label
	end
end
