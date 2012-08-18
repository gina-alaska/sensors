class Group
  include Mongoid::Document

  field :name,          type: String
  field :description,   type: String

  paginates_per 12

  validates_presence_of :name
  validates_uniqueness_of :name

  embeds_many :sensors
  has_and_belongs_to_many :platforms
  has_and_belongs_to_many :events
  has_and_belongs_to_many :graphs
  has_and_belongs_to_many :alerts

  has_many :processed_data
end