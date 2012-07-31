module AlertsHelper
  def alert_commands(selected)
    options_for_select([["Alive","alive"]], "#{selected}")
  end

  def sensors_select(sensors, selected)
    options_from_collection_for_select(sensors, :source_field, :source_field, selected)
  end
end
