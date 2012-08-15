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
    field :log_events,          type: Boolean

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

    has_many :raw_data 
    has_many :processed_data
    has_many :events
    has_many :graphs
    has_many :alerts
    has_many :status

    def async_process_events
      Resque.enqueue(EventProcessor, self.slug, :all)
    end

    def to_param
      self.slug
    end
  end
