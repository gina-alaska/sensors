  class Event
    include Mongoid::Document
    include Mongoid::MultiParameterAttributes

    field :name,                type: String
    field :starts_at,           type: DateTime
    field :ends_at,             type: DateTime
    field :command,             type: String

    validates_presence_of :name
    validates_uniqueness_of :name

    index :starts_at
    index :ends_at
    belongs_to :platform
  end
