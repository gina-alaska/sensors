class Platform
  include Mongoid::Document

  field :slug,                type: String
  field :name,                type: String
  field :platform_metadata,   type: String
  field :geo_location,        type: String
  field :license,             type: String
  field :permissions,         type: String
  field :agency,              type: String
  field :authority,           type: String
  field :no_data_value,       type: String

  validates_presence_of :slug
  validates_uniqueness_of :slug

  index({ slug: 1 }, { unique: true })
  has_and_belongs_to_many :groups
  embeds_many :sensors, as: :sensor_parent
  has_many :raw_data 
  has_many :processed_data 
  has_many :status 

  def async_process_events
    Resque.enqueue(EventProcessor, self.slug, :all)
  end

  def to_param
    self.slug
  end

  def all_group_sensors
    self.groups.collect{ |group| group.sensors.collect(&:source_field)}.flatten.uniq
  end
end
