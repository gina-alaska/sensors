class Group
  include Mongoid::Document

  field :name,                type: String
  field :description,         type: String
  field :graph_length,        type: String

  paginates_per 6

  validates_presence_of :name
  validates_uniqueness_of :name

  embeds_many :sensors, as: :sensor_parent
  belongs_to :organization
  has_and_belongs_to_many :platforms
  has_and_belongs_to_many :users
  has_many :status, dependent: :destroy
  has_many :events, dependent: :destroy
  has_many :graphs, dependent: :destroy
  has_many :alerts, dependent: :destroy
  has_many :processed_data, dependent: :destroy, class_name: "Datum"

  scope :user_groups, ->(user){ where(users: user) }

  def all_raw_sensors
    self.platforms.collect{ |platform| platform.sensors.collect(&:source_field)}.flatten.uniq
  end

  def all_processed_sensors
    self.sensors.asc(:source_field).collect(&:source_field)
  end

  def all_platform_slugs
    self.platforms.collect(&:slug)
  end

  def current_messages(number = 6)
    Statu.where(:platform_id.in => self.platforms.collect(&:id)).desc(:start_time).limit(number)
  end
end