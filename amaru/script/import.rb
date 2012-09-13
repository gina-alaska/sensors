module AmaruRunner
  def data_import(token, group, slug, import, type, config, path)
    case type
      when "csv"
      when "json"
      when "barrow"
        BarrowImport.new(import, config, group, slug, path, token)
      else
        raise "I don't know how to import #{script} type data!"
    end
  end
end
