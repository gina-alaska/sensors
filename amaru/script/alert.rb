module AmaruRunner
  def data_alert(slug, name)
    if name == "alive"
      process_alive                         #process all alive alert commands
    else
      alert = Alert.where(name: name).first
      unless alert.disabled
        alert.async_process_alert(slug)     # Queue the alert event
      end
      puts "Queued alert event for #{name}."
    end
  end

  def process_alive
    puts "Queuing all alive events..."

    alerts = Alert.all
    alerts.each do |alert|
      group = Group.where(id: alert.group_id).first
      events = alert.alert_events
      events.each do |event|
        unless alert.disabled
          if event.command == "alive"
            group.all_platform_slugs.each do |slug|
              puts "slug: #{slug}"
              alert.async_process_alert(slug)    #Queue alive async process
            end
          end
        end
      end
    end
  end
end
