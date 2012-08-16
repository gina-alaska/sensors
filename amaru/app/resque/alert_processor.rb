class AlertProcessor
	@queue = :alerts

#	def self.authorized?(slug, event_id, user)
#		events = get_events(slug, event_id)
#		events.inject(true) { |c,i| c = c && (i.platform.authority == user) }
#	end

	def self.perform(slug, alert_id)
		platform = Platform.where( slug: slug ).first
    alert = Alert.where(id: alert_id).first
		alert_com = AlertCommands.new(platform)

    # Add a status for event
    status = platform.status.build(system: "alert", message: "Processing alert #{alert.name}.", status: "Running", start_time: DateTime.now)
    status.save

#    if DateTime.now < alert.starts_at or DateTime.now > alert.ends_at
#      status.update_attributes(status: "Finished", end_time: DateTime.now)
#      return
#    end

    events = alert.alert_events   	# Get all events from this alert
	  events.each do |event|          # Do all event commands
			method = event.command
  		alert_com.send(method.downcase.to_sym, alert, event, status)
		end
	rescue => e
		puts "Failure!"
		raise
	end
end

class AlertCommands
	def initialize( platform )
		@platform = platform
	end

  # Copy a raw data field to a new field in the processed data collection.
	def alive(alert, event, status)
    starts_at = DateTime.now - eval(event.amounts)
    ends_at = DateTime.now

    raw = @platform.raw_data.captured_between(starts_at, ends_at)
    if raw.count == 0 
      status.update_attributes(status: "ALERT", message: "Platform #{@platform.name} is down, no new data for alert period of #{event.amounts}!", end_time: DateTime.now)
      AlertMailer::alert_email(alert, "Platform #{@platform.name} is down, no new data for alert period of #{event.amounts}!", @platform.name).deliver
    else
      status.update_attributes(status: "Finished", end_time: DateTime.now)
    end
	end
end
