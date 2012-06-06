  class Sensor
    include Mongoid::Document

    field :label,             type: String
    field :source_field,      type: String
    field :sensor_metadata,   type: String

    validates_presence_of :label
    validates_presence_of :source_field
    validates_presence_of :sensor_metadata

    validates_uniqueness_of :source_field
    paginates_per 12

    embedded_in :platform
  end
