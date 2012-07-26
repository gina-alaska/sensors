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
  index :name

  def async_graph_image_process
    Resque.enqueue(GraphImageProcessor, self.platform.slug, self.id)
  end
end
