class EventProcessorSingle
	@queue = :events

	def self.perform(slug, start_time)
    #Bundler.require :processing
    platform = Platform.where(slug: slug).first
    groups = platform.groups

    unless groups.empty?
      groups.each do |group|
    		allevents = group.events
        puts "allevents..."
        puts allevents.inspect

        unless allevents.empty?
          puts "allevents length - #{allevents.length}"
      		allevents.each_with_index do |eventitem, index|		# Process all events for group
            puts "Event - #{eventitem.inspect} Index - #{index}"
            if eventitem.interval == "import" and eventitem.enabled == true
              platform.raw_data.batch_size(1000).captured_between(start_time, nil).each do |data_row|
                output = nil
                # add a status for event
                status = group.status.build(system: "process", message: "processing platform #{platform.name} for field #{eventitem.name}.", status: "Running", start_time: Time.zone.now)
                status.group = group
                status.platform = platform
                status.save

                # Assemble needed raw data fields
                data = []
                eventitem.from.each do |field|
                  data << data_row.send(field)
                end

                processed_data = group.processed_data.no_timeout.where(capture_date: data_row.capture_date).first
                if processed_data.nil?
                  processed_data = group.processed_data.build(capture_date: data_row.capture_date)
                end

                processor = ProcessorCommands.new(group, platform, eventitem)
                processes = eventitem.commands     # get all commands

                processes.each do |cmd|        # do all commands
                  start_time = cmd.starts_at.nil? ? data_row.capture_date : cmd.starts_at
                  end_time = cmd.ends_at.nil? ? data_row.capture_date : cmd.ends_at
                  next unless data_row.capture_date.between?(start_time, end_time)

                  data = processor.send(cmd.command.downcase.to_sym, { cmd: cmd, input: data, data_row: data_row, processed_data: processed_data })
                end
                #status.update_attributes(status: "Finished", end_time: Time.zone.now)
              end
            end
            # Do filters if there are any
            unless eventitem.filter == ""
              window = eval(eventitem.window)
              puts "  Starting #{eventitem.filter} filter:"
              filter_data = group.processed_data.no_timeout.batch_size(1000)

              filter_data.each do |data_row|
                start_time = data_row.capture_date - window
                end_time = data_row.capture_date + window

                input_data = filter_data.captured_between(start_time, end_time).only(:capture_date, eventitem.name.to_sym)
                
                if data_row.send(eventitem.name.to_sym) == platform.no_data_value
                  data = data_row.send(eventitem.name.to_sym)
                else
                  processor = ProcessorCommands.new(group, platform, eventitem)
                  data = processor.send(eventitem.filter.downcase.to_sym, { input: input_data, data_field: eventitem.name })
                end

                data_row.update_attribute("#{eventitem.name}_#{eventitem.filter.downcase}".to_sym, data)
              end
              puts "  End of filter"
            end

            status.update_attributes(status: "Finished", end_time: Time.zone.now)
            puts "Finished process event #{eventitem.name} for #{platform.name}"
      		end
        end
      end
    end
	rescue => e
		puts "Something has gone horribly wrong!"
    puts e.inspect
		raise
	end
end

class ProcessorCommands
  include Processes

	def initialize( group, platform, event )
    @group = group
		@platform = platform
    @event = event
	end
end
