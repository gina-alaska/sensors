class Statu
  include Mongoid::Document

  field :system,              type: String
  field :start_time,          type: DateTime
  field :end_time,            type: DateTime
  field :message,             type: String
  field :status,              type: String

  attr_accessible :system, :start_time, :end_time, :message, :status
  index({ system: 1, start_time: 1 })
  has_and_belongs_to_many :groups
  belongs_to :group
  belongs_to :platform

  scope :latest, ->(number = 6) {
    self.desc(:start_time).limit(number)
  }
end