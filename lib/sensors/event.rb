  class Sensors::Event
    include Mongoid::Document

    field :starts_at,           type: DateTime
    field :ends_at,             type: DateTime
    field :command,             type: String

    index :starts_at
    index :ends_at
    embedded_in :process_sensor, :class_name => "Sensors::ProcessSensor"
  end
