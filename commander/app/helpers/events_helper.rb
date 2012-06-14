module EventsHelper
	def date_display(date)
		if date.nil?
			"Continuous"
		else
			date.strftime("%b %d, %Y - %I:%M%p")
		end
	end

	def datepicker_format(date)
		date.try(:utc).try(:strftime, "%F %T%z")
	end
end
