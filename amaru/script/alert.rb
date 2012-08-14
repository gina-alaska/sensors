module AmaruRunner
  def data_alert(name)
    if name == "alive"
      process_alive                         #process all alive alert commands
    else
      alert = Alert.where(name: name).first
      unless alert.disabled
        alert.async_process_alert           # Queue the alert event
      end
      puts "Queued alert event for #{name}."
    end
  end

  def process_alive
    puts "Queuing all alive events..."

    alerts = Alert.all
    alerts.each do |alert|
      events = alert.alert_events
      events.each do |event|
        unless alert.disabled
          if event.command == "alive"
            alert.async_process_alert       #Queue alive async process
          end
        end
      end
    end
  end
end
