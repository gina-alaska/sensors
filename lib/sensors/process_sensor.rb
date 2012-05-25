  class Sensors::ProcessSensor
    include Mongoid::Document

    field :no_data,             type: Float

    belongs_to :platform,       :class_name => "Sensors::Platform"
    embeds_many :events,        :class_name => "Sensors::Event"
  end
