  class Sensors::Event
    include Mongoid::Document

    field :starts_at,           type: DateTime
    field :ends_at,             type: DateTime
    field :command,             type: String

    index :starts_at
    index :ends_at
    belongs_to :process_sensor, :class_name => "Sensors::ProcessSensor"
  end
