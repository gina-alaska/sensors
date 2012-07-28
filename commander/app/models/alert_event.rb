class AlertEvent
  include Mongoid::Document

  field :index,     type: Integer
  field :command,   type: String
  field :sensors,   type: String
  field :amounts,   type: String
  field :logic,     type: String

  default_scope asc(:index)
  embedded_in :alert
end