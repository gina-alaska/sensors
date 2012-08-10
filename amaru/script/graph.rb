module AmaruRunner
  def data_graph(name, output_name, start_date, end_date)
    graph = Graph.where(name: name).first
    # Queue the graph creation
    graph.async_graph_process(start_date, end_date, output_name)
    puts "Queued graph creation process for #{name}."
  end
end
