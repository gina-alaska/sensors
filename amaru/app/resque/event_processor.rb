#require "processes/copy"
#require "processes/mean"
#require "processes/median"

class EventProcessor
	@queue = :events

	def self.perform(group_id, event_id)
    Bundler.require :processing
		group = Group.where(id: group_id).first
    platforms = group.platforms.all
		if event_id.to_sym == :all
			events = group.events
		else
			events = [group.events.find(event_id)]
		end

    platforms.each do |platform|
  		processor = ProcessorCommands.new(group, platform)

  		events.each do |event|							# Process all events for platform
        # Add a status for event
        status = group.status.build(system: "process", message: "Processing platform #{platform.name} for field #{event.name}", status: "Running", start_time: DateTime.now)
        status.group = group
        status.platform = platform
        status.save

  			processes = event.commands 	  # Get all commands from this event
        previous_command = nil
        no_data = platform.no_data_value

  			processes.each do |process|   # Do all command processes
  				method = process.command
          if previous_command.nil?
            source_data = platform.raw_data
          else
            source_data = previous_command.output_data
          end
    			processor.send(method.downcase.to_sym, event.name, event.from, process, nil, source_data)
          previous_command = process
  			end
        
        previous_command.output_data.update_all(group_id: group.id)
        status.update_attributes(status: "Finished", end_time: DateTime.now)
  		end
    end
	rescue => e
		puts "Something has gone horribly wrong!"
		raise
	end
end

class ProcessorCommands
  include Processes

	def initialize( group, platform )
    @group = group
		@platform = platform
	end
end
