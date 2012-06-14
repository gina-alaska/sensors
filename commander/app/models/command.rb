class Command
	include Mongoid::Document

	field :index,   	type: Integer
	field :starts_at, type: DateTime
	field :ends_at,   type: DateTime
	field :command,   type: String
	field :from,      type: String

	embedded_in :event
end