class Graph
  include Mongoid::Document

  field :name,         type: String
  field :config,       type: String
  field :thumb_path,   type: String
  field :image_path,   type: String
  field :length,       type: String

  validates_presence_of :name
  validates_uniqueness_of :name

  belongs_to :platform
  index({ name: 1 })

  def async_graph_image_process
    Resque.enqueue(GraphImageProcessor, self.platform.slug, self.id)
  end

  def async_graph_process(start_date, end_date, ouput_name)
    Resque.enqueue(GraphProcessor, self.platform.slug, self.id, start_date, end_date, ouput_name)
  end
end
