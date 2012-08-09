#!script/rails runner
# Run import script

script = ARGV[0]
import = ARGV[1]
slug = ARGV[2]
config = ARGV[3]
path = ARGV[4]

case script
  when "csv"
  when "json"
  when "barrow"
    results = BarrowImport.new(import, config, slug, path)
  else
    raise "I don't know how to import #{script} type data!"
end

