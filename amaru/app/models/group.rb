class Group
  include Mongoid::Document

  field :name,          type: String
  field :description,   type: String

  paginates_per 6

  validates_presence_of :name
  validates_uniqueness_of :name

  embeds_many :sensors
  has_and_belongs_to_many :platforms
  has_many :events
  has_many :graphs
  has_many :alerts
  has_many :status
  has_many :processed_data

  def all_raw_sensors
    self.platforms.collect{ |platform| platform.sensors.collect(&:source_field)}.flatten.uniq
  end
end