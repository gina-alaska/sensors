require "processes/copy"
require "processes/mean"

class EventProcessor
	# include DataSave
	@queue = :events

	def self.authorized?(group_id, event_id, user)
		events = get_events(slug, event_id)
		events.inject(true) { |c,i| c = c && (i.platform.authority == user) }
	end

	def self.perform(group_id, event_id)
		group = Group.where(id: group_id).first
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
  include Processes

	def initialize( group, platform )
    @group = group
		@platform = platform
	end
end
