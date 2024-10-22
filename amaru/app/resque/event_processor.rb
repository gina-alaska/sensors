class EventProcessor
	@queue = :events

	def self.perform(group_id, event_id, start_date, end_date)
    #Bundler.require :processing
		group = Group.where(id: group_id).first
    platforms = group.platforms.all
  	event = group.events.where(id: event_id).first
    window = eval(event.window)
    start_date ||= Time.zone.now - 50.years.ago
    end_date ||= Time.zone.now

    platforms.each do |platform|
      # add a status for event
      status = group.status.build(system: "process", message: "processing platform #{platform.name} for field #{event.name}.", status: "Running", start_time: Time.zone.now)
      status.group = group
      status.platform = platform
      status.save

      puts "Started process event #{event.name} for #{platform.name}"

      processes = event.commands    # Get all commands from this event
      unless processes.empty?
        platform.raw_data.captured_between(start_date, end_date).no_timeout.batch_size(1000).each do |data_row|
          output = nil

          # Assemble needed raw data fields
          data = []
          event.from.each do |field|
            data << data_row.send(field) unless field.nil?
          end

          processed_data = group.processed_data.where(capture_date: data_row.capture_date).first_or_initialize

          processor = ProcessorCommands.new(group, platform, event)
          processes.each do |cmd|
            start_time = cmd.starts_at.nil? ? data_row.capture_date : cmd.starts_at
            end_time = cmd.ends_at.nil? ? data_row.capture_date : cmd.ends_at
            next unless data_row.capture_date.between?(start_time, end_time)

            unless cmd.command == "copy"
              data = processor.send(cmd.command.downcase.to_sym, { cmd: cmd, input: data, data_row: data_row, processed_data: processed_data })
            end
          end

          processed_data.update_attribute(event.name.to_sym, data.shift)
        end
      end

      # Do filters if there are any
      unless event.filter == ""
        puts "  Starting #{event.filter} filter for #{event.name}"

        group.processed_data.captured_between(start_date, end_date).batch_size(1000).no_timeout.each do |data_row|
          start_time = data_row.capture_date - window
          end_time = data_row.capture_date + window

          input_data = group.processed_data.captured_between(start_time, end_time).only(:capture_date, event.name.to_sym)
          
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

	rescue => e
		puts "Something has gone horribly wrong!\n\n"
    puts "#{e.inspect}\n\n"
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
