class Event
  include Mongoid::Document

  field :name,                type: String
  field :description,         type: String
  field :from,                type: Array

  validates_presence_of :name
  validates_uniqueness_of :name
  paginates_per 12

  belongs_to :group
  embeds_many :commands
  accepts_nested_attributes_for :commands

  def async_process_event
    Resque.enqueue(EventProcessor, self.group.id, self.id)
  end

end
