class Event
  include Mongoid::Document
  FILTERS = [["Mean", "mean"],["Median", "median"]]

  field :name,                type: String
  field :description,         type: String
  field :from,                type: Array
  field :interval,            type: String
  field :enabled,             type: Boolean, default: true
  field :filter,              type: String
  field :window,              type: String

  validates_presence_of :name
  validates_uniqueness_of :name
  validates_presence_of :from
  paginates_per 12

  belongs_to :group
  embeds_many :commands
  accepts_nested_attributes_for :commands

  def async_process_event
    Resque.enqueue(EventProcessor, self.group.id, self.id, nil, nil)
  end

  def async_process_by_date(start_date, end_date)
    Resque.enqueue(EventProcessor, self.group.id, self.id, start_date, end_date)
  end
end
