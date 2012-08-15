# Main graph object
require 'yaml'

module RvgGraph
  class Graph
    include Magick
    
    def initialize(config, data_hash, no_data)
      # get the graph YAML template
      if File.exists?(config)
        @template = Psych.load_file(config)
      else
        @template = Psych.load(config)
      end

      # build the graph image
      @canvas = RVG.new(@template["graph"]["width"],
           @template["graph"]["height"])

      # graph data
      @data_hash = data_hash

      # no data value
      @no_data = no_data
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
      Dividers.draw(bcord, data_object, @canvas, @data_hash, @no_data)

      # Draw each data graph by type
      data_object.each do |data|
        # Get aggregate information from data
        data_name = data["name"].split(",").first
        puts "data type #{data["type"]}"
        agg = Agg.new(@data_hash, data_name, @no_data)

        case data["type"]
        when "line"
          LineGraph.draw(data, bcord, agg, @canvas, @data_hash, @no_data)
        when "depth"
          DepthGraph.draw(data, bcord, agg, @canvas)
        when "profile"
          ProfileGraph.draw(data, bcord, @canvas, @data_hash, @no_data)
        else
          puts "Unknown graph type #{data["type"]}!!"
          raise
        end

        # Draw any axis and text associated with this data
        Axis.draw(data, bcord, agg, @canvas) if data["axis"]
        draw_text(data["text"]) unless data["text"].nil?
      end

      # Draw graph border
      Border.draw(@template["border"], bcord, @canvas)

      # Draw the graph title if there is one
      draw_title(bcord) if @template["graph"]["title"]
    end

    def save(filename)
      @canvas.draw.write filename
    end

    def draw_title(bcord)
      title_offset = @template["graph"]["title_offset"].to_i
      anchor = "middle"
      anchor = @template["graph"]["title_anchor"] unless @template["graph"]["title_anchor"].nil?
      position = "center"
      position = @template["graph"]["title_position"] unless @template["graph"]["title_position"].nil?
      xpos = bcord.xmin
      case position
      when "left"
        xpos = bcord.xmin
      when "right"
        xpos = bcord.xmax
      when "center"
        xpos = (bcord.xmax-bcord.xmin)/2+bcord.xmin
      end
      @canvas.text(xpos, bcord.ymin-title_offset, @template["graph"]["title"]).styles(:fill=>"black", :font_size=>@template["graph"]["title_size"].to_i, :text_anchor=>anchor)
    end

    def draw_text(text)
      text.each do |item|
        tstyle = Style.new(item["style"])
        text_pos = item["position"].split(",")
        @canvas.text(text_pos[0].to_i, text_pos[1].to_i, item["text"]).styles(:fill=>tstyle.color, :font_size=>tstyle.text_size, :text_anchor=>tstyle.anchor)
      end
    end
  end
end