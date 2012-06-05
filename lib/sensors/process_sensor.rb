  class Sensors::ProcessSensor
    include Mongoid::Document

    field :name,          type: String
    field :no_data,       type: Float

    belongs_to :platform, :class_name => "Sensors::Platform"
    has_many :events,     :class_name => "Sensors::Event", :dependent => :destroy
  end
