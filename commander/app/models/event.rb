  class Event
    include Mongoid::Document
  #  include Mongoid::MultiParameterAttributes

    field :name,                type: String
    field :description,         type: String
    field :from,                type: Array

    validates_presence_of :name
    validates_uniqueness_of :name
    paginates_per 12

    embeds_many :commands
    belongs_to :platform
    accepts_nested_attributes_for :commands

    def async_process_event
      Resque.enqueue(EventProcessor, self.platform.slug, self.id)
    end

  end
