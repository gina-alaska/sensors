require "processes/copy"
require "processes/mean"

class EventProcessorSingle
	@queue = :events

	def self.perform(slug, start_time)
    Bundler.require :processing
    platform = Platform.where(slug: slug).first
    groups = platform.groups

    unless groups.size == 0
      groups.each do |group|
    		events = group.events

        unless events.size == 0
       		processor = ProcessorCommands.new(group, platform)

      		events.each do |event|		# Process all events for group
            if event.interval == "import" and event.enabled == true
              # add a status for event
              status = group.status.build(system: "process", message: "processing platform #{platform.name} for field #{event.name}.", status: "Running", start_time: Time.zone.now)
              status.group = group
              status.platform = platform
              status.save

              processes = event.commands     # get all commands
              processes.each do |process|    # do all commands
                method = process.command
                processor.send(method.downcase.to_sym, event.name, event.from, process, start_time)
              end
              status.update_attributes(status: "Finished", end_time: Time.zone.now)
            end
      		end
        end
      end
    end
	rescue => e
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
