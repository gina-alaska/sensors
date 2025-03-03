# Generate graph and put image in RailsRoot/graphs/platform_slug
# Each image is named by the graph id
# a thumbnail image is generated by RMagick and placed in the same directory
class GraphImageProcessor
  include RvgGraph
  include Magick
  @queue = :graph_image

  def self.perform(group_id, graph_id)
    #Bundler.require :processing
    @group = Group.where(id: group_id).first
    graph = @group.graphs.find(graph_id)

    @group.all_platform_slugs.each do |slug|
      platform = Platform.where(slug: slug).first
      run_time = DateTime.now
      status = @group.status.build(system: "graphs", message: "Building graph #{graph.name} for platform #{platform.name}.", status: "Running", start_time: run_time)
      status.group = @group
      status.platform = platform
      status.save!

      ends_at = platform.raw_data.order_by(:capture_date.asc).last.capture_date
      if graph.length.nil?
        starts_at = ends_at - 1.day
      else
        starts_at = ends_at-eval(graph.length)
      end

      template = Psych.load(graph.config)

      path = File.join('graphs', platform.slug)
      unless File.exists?(path)
        Dir.mkdir(path)
      end
      file = File.join(path, "#{graph_id}.jpg")
      puts "Creating Graph, output to #{file}"

      # Build data hash for graph
      data_hash = Hash.new
      data_hash["date"] = Array.new

      template["data"].each do |tdata|
        case tdata["collection"]
        when "raw"
          data = platform.raw_data.captured_between(starts_at, ends_at)
        when "processed"
          data = @group.processed_data.captured_between(starts_at, ends_at)
        end

        fields = tdata["name"].split(",")

        data.each do |row|
          fields.each do |field|
            data_hash[field] ||= []
            data_hash[field] << row[field.to_sym].to_f
          end
          data_hash['date'] ||= []
          data_hash['date'] << row[:capture_date]
        end
      end

      rvg_graph = Graph.new(graph.config, data_hash, platform.no_data_value)

      rvg_graph.draw
      rvg_graph.save(file)
      thumbfile = File.join(path, "#{graph_id}_thumb.jpg")
      img = Image.read(file).first
      thumb = img.resize_to_fit(200)
      thumb.write(thumbfile)

      # update the database graph image paths and last_run time
      graph.update_attributes(image_path: file, thumb_path: thumbfile, processing: false, last_run: run_time)

      status.update_attributes(status: "Finished", end_time: DateTime.now)
      puts "Done!"
    end
  end
end