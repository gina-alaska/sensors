module AmaruRunner
  def data_import(slug, import, type, config, path)
#    puts "slug: #{slug} import: #{import} type: #{type} config: #{config} path: #{path}"
    case type
      when "csv"
      when "json"
      when "barrow"
        BarrowImport.new(import, config, slug, path)
      else
        raise "I don't know how to import #{script} type data!"
    end
  end
end
