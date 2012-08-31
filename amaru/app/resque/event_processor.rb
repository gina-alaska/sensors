class EventProcessor
	# include DataSave
	@queue = :events

	def self.authorized?(group_id, event_id, user)
		events = get_events(slug, event_id)
		events.inject(true) { |c,i| c = c && (i.platform.authority == user) }
	end

	def self.perform(group_id, event_id)
		group = Group.where(id: group_id).first
#    events = group.events.find(event_id)
    platforms = group.platforms.all
		if event_id.to_sym == :all
			events = group.events
		else
			events = [group.events.find(event_id)]
		end

    platforms.each do |platform|
  		processor = ProcessorCommands.new(group, platform)

      # Read in configuration file if available
  		events.each do |event|							# Process all events for platform
        # Add a status for event
        status = group.status.build(system: "process", message: "Processing platform #{platform.name} for field #{event.name}: #{event.description}.", status: "Running", start_time: DateTime.now)
        status.group = group
        status.platform = platform
        status.save

  			processes = event.commands 				# Get all commands from this event
  			processes.each do |process|       # Do all command processes
  				method = process.command
    			processor.send(method.downcase.to_sym, event.name, event.from, process)
  			end
        status.update_attributes(status: "Finished", end_time: DateTime.now)
  		end
    end
	rescue => e
    #status.update_attributes(status: "Error", message: e.message, end_time: DateTime.now)
		puts "Failure!"
		raise
	end
end

class ProcessorCommands
	def initialize( group, platform )
    @group = group
		@platform = platform
	end

  # Copy a raw data field to a new field in the processed data collection.
	def copy(processed_field, sensors, process)
		sensor = sensors.first
		puts "Copying raw data #{sensor} to processed data #{processed_field}."
		puts "start - #{process.starts_at} end - #{process.ends_at}"
	statats
    raw = @platform.raw_data.captured_between(process.starts_at, process.ends_at).only(:capture_date, sensor.to_sym)
    raw.each do |raw_row|
    	processed = @platform.processed_data.find_or_create_by(
    		  capture_date: raw_row.capture_date)
    	processed.update_attribute(processed_field, raw_row[sensor])
    end
    puts "End Copy"
	end

  # Using R, calculate the mean and put it into a new processed data field.
	def mean(processed_field, sensors, process)
		sensor = sensors.first
		value, units = process.window.split(".")
		window = value.to_i.send(units.to_sym)
		start_date = process.starts_at.nil? ? nil : process.starts_at - window
		end_date = process.ends_at.nil? ? nil : process.ends_at + window

    myr = RinRuby.new(false)

		puts "calculating Mean on raw data #{sensor} to processed data
		    #{processed_field}."
		puts "start - #{process.starts_at} end - #{process.ends_at}"
    raw = @platform.raw_data.captured_between(start_date, end_date).only(:capture_date, sensor.to_sym)

		raw.each do |row|
			data = @platform.raw_data.captured_between(row.capture_date - window, row.capture_date + window).only(sensor.to_sym)

	    # Build array to send to R, convert all no data values to nil.
      rdata = []
      data.each do |value|
      	rawdata = value[sensor.to_sym].to_f == @platform.no_data_value.to_f ? nil : value[sensor.to_sym]
      	rdata.push(rawdata)
      end

	    # Do R mean processing
	    myr.data = rdata.compact
	    myr.eval <<-EOF
	      mdata <- mean(data)
			EOF

      # Push processed data to processed_data collection.
			processed = @platform.processed_data.find_or_create_by(
		    		  capture_date: row.capture_date)
		  processed.update_attribute(processed_field, myr.mdata)
		end

    myr.quit
    puts "End Mean"
	end
end
