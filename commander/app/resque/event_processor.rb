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
		events.each do |e|
			opts = e.arguments.split(/,\s*/)
			method = e.command
			processor.send(method.downcase.to_sym, e.starts_at, e.ends_at, e.name, *opts)
		end
	rescue => e
		puts "Failure!"
		raise
	end

	def self.get_events(slug, event)
		platform = Platform.where( slug: slug ).first
		if event.to_sym == :all
			events = platform.events
		else
			events = [platform.events.find(event)]
		end
	end
end

class ComDsl
	def initialize (platform, starts_at, ends_at, proc_field)
		@platform = platform
		@starts_at = starts_at
		@ends_at = ends_at
		@proc_field = proc_field
	end
end

class ProcessorCommands
	def initialize( platform )
		@platform = platform
	end

  # Copy a raw data field to a new field in the processed data collection.
	def copy(start_date, end_date, processed_field, *sensors)
		sensor = sensors.first
		check_sensor(sensor)
		puts "Copying raw data #{sensor} to processed data #{processed_field}."
		puts "start - #{start_date} end - #{end_date}"
    raw = @platform.raw_data.captured_between(start_date, end_date).only(
    	  :capture_date, sensor.to_sym)
    raw.each do |raw_row|
    	processed = @platform.processed_data.find_or_create_by(
    		  capture_date: raw_row.capture_date)
    	processed.update_attribute(processed_field, raw_row[sensor])
    end
    puts "End Copy"
	end

  # Using R, calculate the mean and put it into a new processed data field.
	def mean(start_date, end_date, processed_field, *sensors)
		sensor = sensors.first
		check_sensor(sensor)
		puts "calculating Mean on raw data #{sensor} to processed data
		    #{processed_field}."
		puts "start - #{start_date} end - #{end_date}"
    raw = @platform.raw_data.captured_between(start_date, end_date).only(
    	  :capture_date, sensor.to_sym)

=begin

raw.each do |row|
	data = @platform.raw_data.captured_between(
		row.capture_date - 90.minutes, row.capture_date + 90.minutes).only(
			:capture_date, sensor.to_sym
	)	
	mean = calc_mean(data)
	processed = @platform.processed_data.find_or_create_by(
    		  capture_date: row.capture_date)
  processed.update_attribute(processed_field, mean)
end

=end

    # Build array to send to R, convert all no data values to nil.
    rdata = raw.collect do |raw_row|
    	raw_row[sensor].to_f == @platform.no_data_value.to_f ? nil : raw_row[sensor]
    end

    # Do R mean processing
    myr = RinRuby.new(false)
    myr.data = rdata.compact
    myr.eval <<-EOF
      library(igraph)
      mdata <- running.mean(data, 12)
		EOF

    # Push processed data to processed_data collection.
    raw.each_with_index do |raw_row, index|
    	processed = @platform.processed_data.find_or_create_by(
    		  capture_date: raw_row.capture_date)
    	processed.update_attribute(processed_field, myr.mdata[index])
    end
    myr.quit
    puts "End Mean"
	end

	def check_sensor(sensor)
  	if @platform.sensors.where(:source_field => sensor).count != 1
    	raise "Unknown sensor #{sensor}!"
    end
	end
end