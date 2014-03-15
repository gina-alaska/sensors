class EventProcessorSingle
	@queue = :events

	def self.perform(slug, start_time)
    #Bundler.require :processing
    platform = Platform.where(slug: slug).first
    groups = platform.groups

    unless groups.empty?
      groups.each do |group|
    		events = group.events

        unless events.empty?
      		events.each do |event|		# Process all events for group
            puts "Event - #{event.name}"
            if event.interval == "import" and event.enabled == true
              platform.raw_data.batch_size(1000).captured_between(start_time, nil).each do |data_row|
                output = nil
                # add a status for event
                status = group.status.build(system: "process", message: "processing platform #{platform.name} for field #{event.name}.", status: "Running", start_time: Time.zone.now)
                status.group = group
                status.platform = platform
                status.save

                # Assemble needed raw data fields
                data = []
                event.from.each do |field|
                  data << data_row.send(field)
                end

                processed_data = group.processed_data.no_timeout.where(capture_date: data_row.capture_date).first
                if processed_data.nil?
                  processed_data = group.processed_data.build(capture_date: data_row.capture_date)
                end

                processor = ProcessorCommands.new(group, platform, event)
                processes = event.commands     # get all commands

                processes.each do |cmd|        # do all commands
                  start_time = cmd.starts_at.nil? ? data_row.capture_date : cmd.starts_at
                  end_time = cmd.ends_at.nil? ? data_row.capture_date : cmd.ends_at
                  next unless data_row.capture_date.between?(start_time, end_time)

                  data = processor.send(cmd.command.downcase.to_sym, { cmd: cmd, input: data, data_row: data_row, processed_data: processed_data })
                end
                status.update_attributes(status: "Finished", end_time: Time.zone.now)
              end
            end
            # Do filters if there are any
            unless event.filter == ""
              window = eval(event.window)
              puts "  Starting filter #{event.filter}"
              filter_data = group.processed_data.no_timeout.batch_size(1000)

              filter_data.each do |data_row|
                start_time = data_row.capture_date - window
                end_time = data_row.capture_date + window

                input_data = filter_data.captured_between(start_time, end_time).only(:capture_date, event.name.to_sym)
                
                if data_row.send(event.name.to_sym) == platform.no_data_value
                  data = data_row.send(event.name.to_sym)
                else
                  processor = ProcessorCommands.new(group, platform, event)
                  data = processor.send(event.filter.downcase.to_sym, { input: input_data, data_field: event.name })
                end

                data_row.update_attribute("#{event.name}_#{event.filter.downcase}".to_sym, data)
              end
              puts "  End of filter"
            end

            status.update_attributes(status: "Finished", end_time: Time.zone.now)
            puts "Finished process event #{event.name} for #{platform.name}"
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
