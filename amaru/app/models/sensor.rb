class Sensor
  include Mongoid::Document

  field :label,             type: String
  field :source_field,      type: String
  field :sensor_metadata,   type: String, default: 'No Metadata'

  validates_presence_of :label
  validates_presence_of :source_field
  validates_presence_of :sensor_metadata

  validates_uniqueness_of :source_field
  paginates_per 8

  index({ source_field: 1 }, { unique: true })
  embedded_in :sensor_parent, polymorphic: true
end
