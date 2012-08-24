class Group
  include Mongoid::Document

  field :name,                type: String
  field :description,         type: String
  field :graph_length,        type: String

  paginates_per 6

  validates_presence_of :name
  validates_uniqueness_of :name

  embeds_many :sensors, as: :sensor_parent
  has_and_belongs_to_many :platforms
  has_many :status
  has_many :events
  has_many :graphs
  has_many :alerts
  has_many :processed_data

  def all_raw_sensors
    self.platforms.collect{ |platform| platform.sensors.collect(&:source_field)}.flatten.uniq
  end

  def all_platform_slugs
    self.platforms.collect(&:slug)
  end

  def current_messages(number = 6)
    self.platforms.collect{ |platform| platform.status.desc(:start_time) }.flatten.values_at(0...number)
  end
end