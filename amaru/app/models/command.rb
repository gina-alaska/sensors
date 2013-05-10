class Command
	include Mongoid::Document

	field :index,         type: Integer
	field :starts_at,     type: DateTime
	field :ends_at,       type: DateTime
	field :command,       type: String
	field :window,        type: String
  field :command_text,  type: String

  has_many :output_data, class_name: "Datum"

  default_scope asc(:index)
	embedded_in :event
end
