class ComDsl
end

mean from: "field", window: 2.days
median from: "field", window: 2.days
average from: ["field1", "field2"]
adjust from: "field", add: 10 or sub: 10
merge from fields to proc

source "field"  # @values = { "dest": raw["field"] }
adjust 12  # @values["dest"] += 12

# @proc_datum.update_attributes(@values)

source "field"  # @values = { "dest": raw["field"] }


adjust 12, cache: "adjusted"  # @values["dest"] += 12
															# @values[params[:cache]] = @values["dest"] if params[:cache]
adjust -10 # @values["dest"] += -10


# @proc_datum.update_attributes(@values) ->
    @proc_datum.update_attributes({ "adjusted" => "+12", "dest" => "+12-10" })

source "fielda", "fieldb"  # @values["dest"] = [raw["fielda"], raw["fieldb"]]

average # size = values.size
        # sum = @values["dest"].inject(:+).to_f
        # @values["dest"] = sum / size



source "fielda" # @values["dest"] = raw["fielda"]
# @proc_datum.update_attributes(@values) ->

def run_it(raw, processed, event)
	@values = source(raw, event.from)

	event.commands.each do |command|
		next unless raw.captured_at.between?(command.starts_at, commands.ends_at)

		if command.from 
			other_data = source(raw, comand.from)
		end

		@values[event.name] = self.send(command.command, 
			{ :command => command, :values => @values, :other => other_data,
				:platform => platform, :event => event })

		if command.cache
			@values[command.cache] = @values[event.name]
		end

	end

	processed.update_attributes(@values)
end