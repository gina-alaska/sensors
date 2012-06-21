class EventProcessor
	include DataSave
	@queue = :events

	def self.authorized?(slug, event_id, user)
		events = get_events(slug, event_id)
		events.inject(true) { |c,i| c = c && (i.platform.authority == user) }
	end

	def self.perform(slug, event)
		platform = Platform.where( slug: slug ).first
		if event.to_sym == :all
			events = platform.events
		else
			events = [platform.events.find(event)]
		end
		processor = ProcessorCommands.new(platform)

		events.each do |event|							# Process all events for platform
			processes = event.commands 				# Get all commands from this event
			processes.each do |process|       # Do all command processes
				method = process.command
  			processor.send(method.downcase.to_sym, event.name, event.from, process)
			end
		end
	rescue => e
		puts "Failure!"
		raise
	end
end

class ProcessorCommands
	def initialize( platform )
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
