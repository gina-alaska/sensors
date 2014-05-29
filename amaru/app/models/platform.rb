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
  field :time_zone,           type: String

  validates_presence_of :slug
  validates_uniqueness_of :slug

  belongs_to :organization
  has_and_belongs_to_many :groups
  embeds_many :sensors, as: :sensor_parent
  has_many :raw_data, class_name: "Datum", dependent: :destroy
#  has_many :processed_data, class_name: "Datum"
  has_many :status  
  has_many :children, class_name: "Platform", inverse_of: :parent
  belongs_to :parent, class_name: "Platform", inverse_of: :children

  index({ slug: 1 }, { unique: true })
  paginates_per 10

  scope :user_platforms, ->(user){ where(users: user) }

  def async_process_event_single(start_time, end_time)
    Resque.enqueue(EventProcessorSingle, self.slug, start_time, end_time)
  end

  def to_param
    self.slug
  end

  def all_group_sensors
    self.groups.collect{ |group| group.sensors.collect(&:source_field)}.flatten.uniq
  end
end
