class Command
	include Mongoid::Document

	field :index,   	type: Integer
	field :starts_at, type: DateTime
	field :ends_at,   type: DateTime
	field :command,   type: String
	field :window,    type: String

  default_scope asc(:index)
	embedded_in :event
end