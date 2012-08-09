def data_import(slug, import, type, config)
  case type
    when "csv"
    when "json"
    when "barrow"
      results = BarrowImport.new(import, config, slug, path)
    else
      raise "I don't know how to import #{script} type data!"
  end
end
