# Amaru scheduler
#
# Checks to see if there is a process that needs to run.
#

class Scheduler

  # Check for graphs that need to run:
  def self.graphs
    graphs = Graph.all
    graphs.each do |graph|
      next if graph.disabled
      run_time = Time.now
      run_when = graph.run_when
      last_run = graph.last_run

      case run_when
      when "5 Min"
        graph.async_graph_image_process
        graph.update_attributes(last_run: run_time, processing: true)
      when "15 Min"
        if time >= last_run + 15.min
          async_graph(graph, run_time)
        end
      when "30 Min"
        if time >= last_run + 30.min
          async_graph(graph, run_time)
        end
      when "1 hour"
        if time >= last_run + 1.hour
          async_graph(graph, run_time)
        end
      when "12 hour"
        if time >= last_run + 12.hours
          async_graph(graph, run_time)
        end
      when "1 day"
        if time >= last_run + 1.day
          async_graph(graph, run_time)
        end
      when "1 week"
        if time >= last_run + 1.week
          async_graph(graph, run_time)
        end
      when "1 month"
        if time >= last_run + 1.month
          async_graph(graph, run_time)
        end
      end
    end
  end

  # queue graph to process and set last run time
  def async_graph(graph, run_time)
    unless graph.processing == true
      graph.async_graph_image_process
      graph.update_attributes(last_run: run_time, processing: true)
    end
  end
end