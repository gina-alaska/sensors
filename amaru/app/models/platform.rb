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
  field :graph_length,        type: String

  validates_presence_of :slug
  validates_presence_of :name
  validates_presence_of :platform_metadata
  validates_presence_of :geo_location
  validates_presence_of :license
  validates_presence_of :permissions
  validates_presence_of :agency
  validates_presence_of :authority

  validates_uniqueness_of :slug

  index({ slug: 1 }, { unique: true })
  embeds_many :sensors
  has_and_belongs_to_many :groups
  has_and_belongs_to_many :events
  has_and_belongs_to_many :graphs
  has_and_belongs_to_many :alerts

  has_many :raw_data 
#  has_many :processed_data

  def async_process_events
    Resque.enqueue(EventProcessor, self.slug, :all)
  end

  def to_param
    self.slug
  end
end
