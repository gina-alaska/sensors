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

  index({ starts_at: 1 })
  index({ ends_at: 1 })
  embeds_many :alert_events
  accepts_nested_attributes_for :alert_events
  has_and_belongs_to_many :groups

  def async_process_alert
    Resque.enqueue(AlertProcessor, self.platform.slug, self.id)
  end
end