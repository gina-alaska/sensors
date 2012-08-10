module AmaruRunner
  def data_process(name)
    event = Event.where(name: name).first
    event.async_process_event # Queue the processing event
    puts "Queued process event for #{name}."
  end
end
