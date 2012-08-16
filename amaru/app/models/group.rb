class Group
  include Mongoid::Document

  field :name,          type: String
  field :description,   type: String

  validates_presence_of :name
  validates_uniqueness_of :name

  has_and_belongs_to_many :platforms
  has_many :events
  has_many :graphs
  has_many :alerts
  has_many :status
end