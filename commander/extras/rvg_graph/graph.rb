# Main graph object
module RvgGraph
  class Graph
    include Magick
  #    attr_accessor :template, :canvas

    def initialize(slug, graph_id, starts_at, ends_at)
      # get the platform
      @platform = Platform.where(slug: slug).first

      # get the graph YAML configuration
      graph = @platform.graphs.find(graph_id)
      @template = Psych.load(graph.config)

      # build the graph image
      @canvas = RVG.new(@template["graph"]["width"],
           @template["graph"]["height"])

      # Set date range
      @start_date = starts_at
      @end_date = ends_at
    end

    def draw
      # Generate graph background
      background_img = Background.generate(@template["graph"])
      @canvas.background_image = background_img
      dstyle = Style.new(@template["border"]["style"])
      if dstyle.bg_color
        bcord = Bounds.new(@template["graph"]["graph_bounds"])
        @canvas.rect(bcord.x_len, bcord.y_len, bcord.xmin, bcord.ymin).styles(:fill=>dstyle.bg_color)
      end
      data_object = @template["data"]

      # Get graph border information
      bcord ||= Bounds.new(@template["graph"]["graph_bounds"])
      if bcord.nil?
        puts "No graph_bounds defined in template!"
        raise
      end

      # Draw any dividing lines for each object
      Dividers.draw(bcord, data_object, @canvas, @platform, @start_date, @end_date)

      # Draw each data graph by type
      data_object.each do |data|
        # Get aggregate information from data
        agg = Agg.new(data["collection"], data["data_fields"].split(",").first, @platform, @start_date, @end_date)

        case data["type"]
        when "line"
          LineGraph.draw(data, bcord, agg, @platform, @canvas, @start_date, @end_date)
        when "depth"
          DepthGraph.draw(data, bcord, agg, @platform, @canvas)
        when "profile"
#          ProfileGraph.draw(data, bcord, agg, @platform, @canvas, @start_date, @end_date)
        else
          puts "Unknown graph type #{data["type"]}!!"
          raise
        end

        # Draw any axis and text associated with this data
        Axis.draw(data, bcord, agg, @canvas) if data["axis"]
#        draw_text(data["text"])
      end

      # Draw graph border
      Border.draw(@template["border"], bcord, @canvas)

      # Draw the graph title if there is one
      draw_title(bcord) if @template["graph"]["title"]
    end

    def save(filename)
      @canvas.draw.write filename
    end

  private

    def draw_title(bcord)
      title_offset = @template["graph"]["title_offset"].to_i
#      @canvas.text((bcord.xmax-bcord.xmin)/2+bcord.xmin, bcord.ymin-title_offset, @template["graph"]["title"]).styles(:fill=>"black", :font_size=>@template["graph"]["title_size"].to_i, :font_family=>'Verdana', :text_anchor=>"middle")
      @canvas.text((bcord.xmax-bcord.xmin)/2+bcord.xmin, bcord.ymin-title_offset, @template["graph"]["title"]).styles(:fill=>"black", :font_size=>@template["graph"]["title_size"].to_i, :text_anchor=>"middle")
    end
  end
end