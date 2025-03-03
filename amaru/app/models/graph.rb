class Graph
  include Mongoid::Document

  field :name,         type: String
  field :config,       type: String
  field :thumb_path,   type: String
  field :image_path,   type: String
  field :length,       type: String
  field :run_when,     type: String
  field :last_run,     type: Time
  field :disabled,     type: Boolean
  field :processing,   type: Boolean

  validates_presence_of :name
  validates_uniqueness_of :name

  belongs_to :group
  index({ name: 1 })

  def async_graph_image_process
    Resque.enqueue(GraphImageProcessor, self.group.id, self.id)
  end

  def async_graph_process(start_date, end_date, output_name)
    Resque.enqueue(GraphProcessor, self.group.id, self.id, start_date, end_date, output_name)
  end
end
