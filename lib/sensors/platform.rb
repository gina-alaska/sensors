  class Sensors::Platform
    include Mongoid::Document

    field :slug,                type: String
    field :name,                type: String
    field :platform_metadata,   type: String
    field :geo_location,        type: String
    field :license,             type: String
    field :permissions,         type: String
    field :agency,              type: String
    field :authority,           type: String

    validates_presence_of :slug
    validates_presence_of :name
    validates_presence_of :platform_metadata
    validates_presence_of :geo_location
    validates_presence_of :license
    validates_presence_of :permissions
    validates_presence_of :agency
    validates_presence_of :authority

    validates_uniqueness_of :slug

    embeds_many :sensors,     :class_name => "Sensors::Sensor"
    has_many :raw_data,       :class_name => "Sensors::RawDatum"
    has_many :processed_data, :class_name => "Sensors::ProcessedDatum"
    has_one :process_sensor,  :class_name => "Sensors::ProcessSensor"
    has_many :alerts,         :class_name => "Sensors::Alerts"

    def to_param
      self.slug
    end
  end
