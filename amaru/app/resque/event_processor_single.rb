class EventProcessorSingle
	@queue = :events

	def self.perform(slug, start_time, end_time)
    #Bundler.require :processing
    platform = Platform.where(slug: slug).first
    groups = platform.groups
    status = nil
    end_time ||= Time.zone.now

    unless groups.empty?
      groups.each do |group|
    		allevents = group.events

        unless allevents.empty?
      		allevents.each do |eventitem|		# Process all events for group
            puts "Event - #{eventitem.inspect}\nStart Time: #{start_time}"
            if eventitem.interval == "import" and eventitem.enabled == true
              # add a status for event
              status = group.status.build(system: "process", message: "processing platform #{platform.name} for field #{eventitem.name}.", status: "Running", start_time: Time.zone.now)
              status.group = group
              status.platform = platform
              status.save

              platform.raw_data.batch_size(1000).captured_between(start_time, end_time).each do |data_row|
                output = nil

                # Assemble needed raw data fields
                data = []
                eventitem.from.each do |field|
                  data << data_row.send(field) unless field.nil?
                end

                # pull or create processed data so that it is available to commands
                processed_data = group.processed_data.where(capture_date: data_row.capture_date).first_or_initialize

                processor = ProcessorCommands.new(group, platform, eventitem)
                processes = eventitem.commands     # get all commands

                processes.each do |cmd|        # do all commands
                  proc_start_time = cmd.starts_at.nil? ? data_row.capture_date : cmd.starts_at
                  proc_end_time = cmd.ends_at.nil? ? data_row.capture_date : cmd.ends_at
                  next unless data_row.capture_date.between?(proc_start_time, proc_end_time)

                  unless cmd.command == "copy"
                    data = processor.send(cmd.command.downcase.to_sym, { cmd: cmd, input: data, data_row: data_row, processed_data: processed_data })
                  end
                end
                processed_data.update_attribute(eventitem.name.to_sym, data.shift)
              end

              # Do filters if there are any
              unless eventitem.filter == ""
                window = eval(eventitem.window)
                puts "  Starting #{eventitem.filter} filter:"
                filter_data = group.processed_data.no_timeout.batch_size(1000).captured_between(start_time, end_time)

                filter_data.each do |data_row|
                  filter_start_time = data_row.capture_date - window
                  filter_end_time = data_row.capture_date + window

                  input_data = filter_data.captured_between(filter_start_time, filter_end_time).only(:capture_date, eventitem.name.to_sym)
                  
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
