  class Alert
    include Mongoid::Document
    include Mongoid::MultiParameterAttributes

    field :starts_at,           type: DateTime
    field :ends_at,             type: DateTime
    field :command,             type: String

    index :starts_at
    index :ends_at
    belongs_to :platform
  end