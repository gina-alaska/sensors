  class Alert
    include Mongoid::Document
    include Mongoid::MultiParameterAttributes

    field :name,                type: String
    field :starts_at,           type: DateTime
    field :ends_at,             type: DateTime
    field :emails,              type: String
    field :message,             type: String
    field :send_to,             type: String
    field :disabled,            type: Boolean

    index :starts_at
    index :ends_at
    embeds_many :alert_events
    belongs_to :platform
  end