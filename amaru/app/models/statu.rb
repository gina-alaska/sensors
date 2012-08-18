class Statu
  include Mongoid::Document
#  include Mongoid::MultiParameterAttributes

  field :system,              type: String
  field :start_time,          type: DateTime
  field :end_time,            type: DateTime
  field :message,             type: String
  field :status,              type: String

  attr_accessible :system, :start_time, :end_time, :message, :status
  index({ system: 1, start_time: 1 })
  belongs_to :groups

  scope :latest, ->(number = 6) {
    self.desc(:start_time).limit(number)
  }
end