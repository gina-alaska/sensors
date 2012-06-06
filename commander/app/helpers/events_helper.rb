module EventsHelper
	def date_display(date)
		if date.nil?
			"Continuous"
		else
			date.strftime("%b %d, %Y - %I:%M%p")
		end
	end
end
