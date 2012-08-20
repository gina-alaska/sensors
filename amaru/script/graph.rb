module AmaruRunner
  def data_graph(name, output_name, start_date, end_date, dump)
    graph = Graph.where(name: name).first
    if dump
      fileout = File.open(output_name, "w")
      fileout.write(graph.config.to_yaml)
      fileout.close
      puts "Dumped graph template for #{name}."
    else
      # Queue the graph creation
      graph.async_graph_process(start_date, end_date, output_name)
      puts "Queued graph creation process for #{name}."
    end
  end
end
