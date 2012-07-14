#
# Ginagraph object
#
require 'rvg/rvg'

module RvgGraph
  class Ginagraph
    include Magick
    attr_accessor :template

    def initialize(slug, graph_id, starts_at, ends_at)
      # get the platform
      @platform = Platform.where(slug: slug).first
      # get the graph YAML configuration
      graph = @platform.graphs.find(graph_id)
      @template = Psych.load(graph.config)

      # build the graph image
      @canvas = RVG.new(@template["graph"]["width"],
           @template["graph"]["height"])
      background_img = gen_background_img(@template["graph"])
      @canvas.background_image = background_img

      # Set date range
      @start_date = starts_at
      @end_date = ends_at
    end

    def save(filename)
      @canvas.draw.write filename
    end

    def draw_title
      bcord = @template["graph"]["graph_bounds"].split(",")
      @canvas.text((bcord[2].to_i-bcord[0].to_i)/2+bcord[0].to_i,
          bcord[1].to_i-14, @template["graph"]["title"]).styles(
          :fill=>"black", :font_size=>@template["graph"]["title_size"].to_i,
          :font_family=>'Verdana', :text_anchor=>"middle")
    end

    def draw_data(data_object)
      bcord = @template["graph"]["graph_bounds"].split(",")
      x_min = bcord[0].to_f
      x_max = bcord[2].to_f

      data_object.each do |data|
        collection = data["collection"]
        data_field = data["data_fields"].split(",").first
        dstyle = GraphStyle.new(data["style"])
        direction = data["direction"]
        range = data["range"].split(",")
        top = range[0].to_f
        bottom = range[1].to_f
        unless data["mark"].nil?
          marks = data["mark"].split(",")
          mark_high = marks[1].to_i if marks[0] == "high"
          mark_low = marks[1].to_i if marks[0] == "low"
        end
        data_top = data["graph_top"]

        agg_results = agg_data(collection, data_field)
        maxval = agg_results[:maxv].to_f
        minval = agg_results[:minv].to_f
        count = agg_results[:count].to_f

        data["maxval"] = maxval
        data["minval"] = minval

        hard_min = data["hard_min"].nil? ? nil : data["hard_min"].to_f
        hard_max = data["hard_max"].nil? ? nil : data["hard_max"].to_f

        savemax = maxval
        savemin = minval
        minval = hard_min unless hard_min.nil?
        maxval = hard_max unless hard_max.nil?

        oldrange = (maxval - minval).to_f

        case collection
        when "processed"
          result = @platform.processed_data.captured_between(@start_date, @end_date).only(:captured_date, data_field.to_sym)
        when "raw"
          result = @platform.raw_data.captured_between(@start_date, @end_date).only(:captured_date, data_field.to_sym)
        else
          puts "Unknown collection command #{collection} in graph configuration!"
          raise
        end

        ratiox = (x_max - x_min)/count
        newrange = (bottom - top).to_f
        newx = x_min
        newy = 0

        if dstyle.fill_color
          firstnum = result.first[data_field.to_sym].to_f
          if data_top == "negative"
            firsty = (((firstnum - minval) * newrange) / oldrange) + top
          else
            firsty = bottom - (((firstnum - minval) * newrange) / oldrange)
          end
          lastnum = result.last[data_field.to_sym].to_f
          if data_top == "negative"
            lasty = (((lastnum - minval) * newrange) / oldrange) + top
          else
            lasty = bottom - (((lastnum - minval) * newrange) / oldrange)
          end

          path = "M "
          result.each do |row|
            vdata = row[data_field.to_sym].to_f
            if vdata == @platform.no_data_value.to_f
              newx += ratiox
              next
            end
            if data_top == "negative"
              newy = (((vdata - minval) * newrange) / oldrange) + top
            else
              newy = bottom - (((vdata - minval) * newrange) / oldrange)
            end
            path += "#{newx.to_i} #{newy.to_i} L "
            newx += ratiox
          end
          if dstyle.fill_to == "top"
            path += "#{x_max.to_i} #{lasty.to_i} L #{x_max.to_i} #{top.to_i}
            L #{x_min.to_i} #{top.to_i} L #{x_min.to_i} #{firsty.to_i} z"
          else
            path += "#{x_max.to_i} #{lasty.to_i} L #{x_max.to_i} #{bottom.to_i}
                 L #{x_min.to_i} #{bottom.to_i} L #{x_min.to_i} 
                 #{firsty.to_i} z"
          end
          @canvas.path(path).styles(:stroke=>dstyle.fill_color, :fill=>dstyle.fill_color, :stroke_width=>"0.8")
        end

        newx = x_min.to_f
        savx = x_min.to_f
        savy = 0

        result.each do |row|
          vdata = row[data_field.to_sym].to_f
          if vdata == @platform.no_data_value.to_f
            savy = 0
            savx = newx
            newx += ratiox
            next
          end

          if data_top == "negative"
            newy = (((vdata - minval) * newrange) / oldrange) + top
          else
            newy = bottom - (((vdata - minval) * newrange) / oldrange)
          end
 #         puts "newy #{newy} bot #{bottom} vdata #{vdata} minv #{minval} maxv #{maxval} nran #{newrange} oran #{oldrange} top #{top}"

          if vdata == savemax and mark_high
            @canvas.line(newx, newy-mark_high, newx, newy+mark_high).
                styles(:stroke=>"red")
          end

          if vdata == savemin and mark_low
            @canvas.line(newx, newy-mark_low, newx, newy+mark_low).
                styles(:stroke=>"red")
          end

          if savy == 0
            savy = newy
            savx = newx
            newx += ratiox
            next
          else
            @canvas.line(savx.to_i, savy.to_i, newx.to_i, newy.to_i).styles(:stroke=>dstyle.color, :stroke_width=>dstyle.line_size, :stroke_linecap=>"round")
          end
          savx = newx
          savy = newy
          newx += ratiox
        end
        @canvas.line(savx.to_i, savy.to_i, newx.to_i, savy.to_i).styles(:stroke=>dstyle.color, :stroke_width=>dstyle.line_size, :stroke_linecap=>"round")

        # Draw any axis associated with this data
        draw_axis(data, agg_results)
      end
    end

    def draw_axis(data, agg)
      axis = data["axis"]
      return unless axis
      bcord = @template["graph"]["graph_bounds"].split(",")
      x_min = bcord[0].to_f
      x_max = bcord[2].to_f
      y_min = bcord[1].to_f
      y_max = bcord[3].to_f
      range = data["range"].split(",")
      range_min = range[0].to_f
      range_max = range[1].to_f
      data_top = data["graph_top"]
      hard_min = data["hard_min"].nil? ? nil : data["hard_min"].to_f
      hard_max = data["hard_max"].nil? ? nil : data["hard_max"].to_f

      axis.each do |daxis|
        dstyle = GraphStyle.new(daxis["style"])
        place = daxis["placement"]
        direction = "x" if place == "top" or place == "bottom"
        direction = "y" if place == "left" or place == "right"
        major_tics = daxis["major"].to_f
        minor_tics = daxis["minor"].to_f
        major_ticlen ||= daxis["major_len"].to_i
        minor_ticlen ||= daxis["minor_len"].to_i
        tic_offset = daxis["offset"].to_i

        case direction
        when "x"
          if data["direction"] == "x-axis"
            gmax = x_max
            gmin = x_min
          else
            gmax = range_max
            gmin = range_min
          end
        when "y"
          if data["direction"] == "y-axis"
            gmax = y_max
            gmin = y_min
          else
            gmax = range_max
            gmin = range_min
          end
        end

        label = daxis["label"]
        dmax = agg[:maxv].to_f
        dmin = agg[:minv].to_f
        dmin = hard_min unless hard_min.nil?
        dmax = hard_max unless hard_max.nil?
        hard_min = dmin if hard_min.nil?
        hard_max = dmax if hard_max.nil?

        # date axis
        if label["units"] == "date"
          dmin = agg[:capture_min].utc.to_i
          dmax = agg[:capture_max].utc.to_i
          hard_max = dmax
        end

        # Convert units if needed
        unless label["units"].nil?
          dmin = conv_units(data["units"], label["units"], dmin).to_f
          dmax = conv_units(data["units"], label["units"], dmax).to_f
          hard_max = conv_units(data["units"], label["units"], hard_max).to_f
        end

        # Find nice number range for axis tics/labels
        unless label["units"] == "date"
          nice_range = nicenum(dmax - dmin, false)
          nice_tic_delta = nicenum(nice_range/(major_tics - 1), true).to_f
          nice_min = (dmin / nice_tic_delta).floor * nice_tic_delta
          nice_max = (dmax / nice_tic_delta).ceil * nice_tic_delta
          minor_delta = nice_tic_delta / minor_tics unless minor_tics.nil?
        else
          drange = dmax - dmin
          nice_min = dmin
          nice_max = dmax
          if drange < 3600            # 1 hour
            nice_tic_delta = 300      # 5 min
            minor_delta = 30          # 30 sec
          elsif drange < 86400        # 1 day
            nice_tic_delta = 3600     # 1 hour
            minor_delta = 600         # 10 min
          elsif drange < 604800       # 1 week
            nice_tic_delta = 86400    # 1 day
            minor_delta = 3600        # 1 hour
          elsif drange < 2678400      # 1 month
            nice_tic_delta = 86400    # 1 day
            minor_delta = 43200       # 12 hours
          else
            nice_tic_delta = 2678400  # month
            minor_delta = 86400       # 1 day
          end
        end

        # Draw major tics and labels
        pos = nice_min
        round = label["round"]

        while pos <= nice_max do 
          if data_top == "negative"  # THIS NEEDS WORK, NOT DONE YET!!
            if direction == "x" and data["direction"] == "x-axis"
              gpos = (((pos - nice_min) * (gmax-gmin)) / (dmax-dmin)) + x_min
            else
              gpos = (((pos - nice_min) * (gmax-gmin)) / (dmax-dmin)) + range_min
            end
          else
            if direction == "x" and data["direction"] == "x-axis"
              gpos = x_max - (((pos - nice_min) * (gmax-gmin)) / (dmax-dmin))
            else
              gpos = range_max - (((pos - nice_min) * (gmax-gmin)) / (dmax-dmin))
            end
          end
          ttext = pos
          ttext = Time.at(pos).utc.strftime("%d %b") if label["units"] == "date"

          case place
          when "top"
            @canvas.line(gpos.to_i, y_min.to_i, gpos.to_i, (y_min + major_ticlen).to_i).styles(:stroke=>dstyle.color, :stroke_width=>dstyle.line_size)
            @canvas.text(gpos.to_i, y_min.to_i - tic_offset, text_format(ttext, round)).styles(:fill=>dstyle.color, :font_size=>dstyle.text_size, :font_family=>'Verdana', :text_anchor=>"middle")
          when "bottom"
            @canvas.line(gpos.to_i, y_max.to_i, gpos.to_i, (y_max - major_ticlen).to_i).styles(:stroke=>dstyle.color, :stroke_width=>dstyle.line_size)
            @canvas.text(gpos.to_i, y_max.to_i + tic_offset, text_format(ttext, round)).styles(:fill=>dstyle.color, :font_size=>dstyle.text_size, :font_family=>'Verdana', :text_anchor=>"middle")
          when "left"
            @canvas.line(x_min.to_i, gpos.to_i, (x_min + major_ticlen).to_i, gpos.to_i).styles(:stroke=>dstyle.color, :stroke_width=>dstyle.line_size)
            @canvas.text(x_min.to_i - tic_offset, gpos.to_i, text_format(ttext, round)).styles(:fill=>dstyle.color, :font_size=>dstyle.text_size, :font_family=>'Verdana', :text_anchor=>"end", :baseline_shift=>-((dstyle.text_size-2)/2))
          when "right"
            @canvas.line(x_max.to_i, gpos.to_i, (x_max - major_ticlen).to_i, gpos.to_i).styles(:stroke=>dstyle.color, :stroke_width=>dstyle.line_size)
            @canvas.text(x_max.to_i + tic_offset, gpos.to_i, text_format(ttext, round)).styles(:fill=>dstyle.color, :font_size=>dstyle.text_size, :font_family=>'Verdana', :text_anchor=>"end", :baseline_shift=>-((dstyle.text_size-2)/2))
          end

          unless minor_tics.nil? or pos == nice_max
            mtic = pos
            while mtic <= (pos + nice_tic_delta)
              if data_top == "negative"  # THIS NEEDS WORK, NOT DONE YET!!
                if direction == "x" and data["direction"] == "x-axis"
                  mpos = (((mtic - nice_min) * (gmax-gmin)) / (dmax-dmin)) + x_min
                else
                  mpos = (((mtic - nice_min) * (gmax-gmin)) / (dmax-dmin)) + range_min
                end
              else
                if direction == "x" and data["direction"] == "x-axis"
                  mpos = x_max - (((mtic - nice_min) * (gmax-gmin)) / (dmax-dmin))
                else
                  mpos = range_max - (((mtic - nice_min) * (gmax-gmin)) / (dmax-dmin))
                end
              end
              case place
              when "top"
                @canvas.line(mpos.to_i, y_min.to_i, mpos.to_i, (y_min + minor_ticlen).to_i).styles(:stroke=>dstyle.color, :stroke_width=>dstyle.line_size)
              when "bottom"
                @canvas.line(mpos.to_i, y_max.to_i, mpos.to_i, (y_max - minor_ticlen).to_i).styles(:stroke=>dstyle.color, :stroke_width=>dstyle.line_size)
              when "left"
                @canvas.line(x_min.to_i, mpos.to_i, (x_min + minor_ticlen).to_i, mpos.to_i).styles(:stroke=>dstyle.color, :stroke_width=>dstyle.line_size)
              when "right"
                @canvas.line(x_max.to_i, mpos.to_i, (x_max - minor_ticlen).to_i, mpos.to_i).styles(:stroke=>dstyle.color, :stroke_width=>dstyle.line_size)
              end
              mtic += minor_delta
            end
          end

          pos += nice_tic_delta
          break if pos > hard_max 
        end

        # Draw axis label
        unless label["units"] == "date"
          lpos = (gmax - gmin)/2 + range_min
        else
          lpos = (gmax - gmin)/2 + gmin
        end
        middle = multiline_middle(label)
        case place
        when "top"
          @canvas.styles(:fill=>dstyle.color, :font_size=>label["size"].to_i, :font_family=>'Verdana', :text_anchor=>'end', :baseline_shift=>-((label["size"]-2)/2)) do |txt|
            label["text"].split("\n").each_with_index do |line, index|
              txt.text(lpos - middle, y_min-label["offset"]).tspan(line).d(0,label["size"] * index)
            end
          end
        when "bottom"
          @canvas.styles(:fill=>dstyle.color, :font_size=>label["size"].to_i, :font_family=>'Verdana', :text_anchor=>'end', :baseline_shift=>-((label["size"]-2)/2)) do |txt|
            label["text"].split("\n").each_with_index do |line, index|
              txt.text(lpos, y_max+label["offset"]).tspan(line).d(0,label["size"] * index)
            end
          end
        when "left"
          @canvas.styles(:fill=>dstyle.color, :font_size=>label["size"].to_i, :font_family=>'Verdana', :text_anchor=>'end', :baseline_shift=>-((label["size"]-2)/2)) do |txt|
            label["text"].split("\n").each_with_index do |line, index|
              txt.text(x_min-label["offset"], lpos - middle).tspan(line).d(0,label["size"] * index)
            end
          end
        when "right"
          @canvas.styles(:fill=>dstyle.color, :font_size=>label["size"].to_i, :font_family=>'Verdana', :text_anchor=>'end', :baseline_shift=>-((label["size"]-2)/2)) do |txt|
            label["text"].split("\n").each_with_index do |line, index|
              txt.text(x_max+label["offset"], lpos - middle).tspan(line).d(0,label["size"] * index)
            end
          end
        end
      end
    end

    def text_format(text, round)
      ntext = text
      unless text.is_a? String
        ntext = sprintf("%0.#{round}f", text)
      end
      return ntext
    end

    def multiline_middle(label)
      temp = label["text"].split("\n")
      height = (temp.length * label["size"]) / 2
    end

    # Thanks Heckbert!
    def nicenum(range, round)
      exponent = Math.log10(range).floor
      fnum = range / (10 ** exponent)
      if round
        if (fnum < 1.5)
          nice_fnum = 1
        elsif fnum < 3
          nice_fnum = 2
        elsif fnum < 7
          nice_fnum = 5
        else
          nice_fnum = 10
        end
      else 
        if fnum <= 1
          nice_fnum = 1
        elsif fnum <= 2
          nice_fnum = 2
        elsif fnum <= 5
          nice_fnum = 5
        else
          nice_fnum = 10
        end
      end

      return nice_fnum * (10 ** exponent)
    end

    def draw_border(border_object)
      bstyle = GraphStyle.new(border_object["style"])
      bcord = @template["graph"]["graph_bounds"].split(",")

      # Clean up border area
      (1..4).each do |num|
        numt = num*2
        @canvas.rect((bcord[2].to_i-bcord[0].to_i)+numt,
           (bcord[3].to_i-bcord[1].to_i)+numt,
           bcord[0].to_i-num, bcord[1].to_i-num).styles(:stroke=>bstyle.fill_color,
           :stroke_width=>bstyle.line_size, :fill_opacity=>0)
      end

      # Draw border
      @canvas.rect(bcord[2].to_i-bcord[0].to_i, bcord[3].to_i-bcord[1].to_i,
           bcord[0].to_i, bcord[1].to_i).styles(:stroke=>bstyle.color,
           :stroke_width=>bstyle.line_size, :fill_opacity=>0)

      # Build break lines
      if blbox ||= border_object["break_line"].split(",")
        y_pos = blbox[0].to_i
        skew = blbox[3].to_i
        width = blbox[1].to_i
        thick = blbox[2].to_i
        break_line = RVG::Group.new do |bline|
          bline.rect(width,thick,0,0).styles(:fill=>bstyle.fill_color,
              :stroke=>bstyle.fill_color)
          bline.line(0,0,width,0).styles(:stroke=>bstyle.color, :stroke_width=>bstyle.line_size+0.5)
          bline.line(0,thick,width,thick).styles(:stroke=>bstyle.color,
              :stroke_width=>bstyle.line_size+0.5)
        end
        # Draw break lines
        @canvas.use(break_line, bcord[0].to_i,
            y_pos).translate(-width/2).skewY(skew)
        @canvas.use(break_line, bcord[2].to_i,
            y_pos).translate(-width/2).skewY(skew)
      end
    end

    def draw_dividers(divider_object)
      line_size = divider_object["line_size"]
      color = "rgb(#{divider_object["color"]})"
      bcord = @template["graph"]["graph_bounds"].split(",")
      x_min = bcord[0].to_i
      x_max = bcord[2].to_i
      top = bcord[1].to_i
      bottom = bcord[3].to_i
      major_tic = divider_object["major_tics"].to_i
      divide_type = divider_object["divider_type"].split(",")
      diva = divide_type[0].to_i
      divb = divide_type[1].to_i

      # calculate tics
      days = self.date["days"]
      width = x_max - x_min
      day_width = (width/days).to_i
      
      # draw divider lines
      mtic = 1
      x_min.step(x_max, day_width) do |x|
        if mtic == major_tic
          mtic = 1
          @canvas.line(x, top, x, bottom).styles(
              :stroke_width=>line_size,
              :stroke_dasharray=>[diva,divb],
              :fill=>'none', :stroke=>color )
        else
          mtic += 1
        end
      end
    end

    def gen_background_img(graph)
      bg_color = "rgb(#{graph["background_color"]})"
      img_x = graph["width"].to_i
      img_y = graph["height"].to_i
      image = Image.new(img_x, img_y) {
        self.background_color = bg_color
      }

      unless graph["graph_gradients"].nil?
        bounds = graph["graph_bounds"]
        img_bounds = bounds.split(",")
        gradimg = graph_gradients(bounds, graph["graph_gradients"])
        image = image.composite(gradimg, img_bounds[0].to_i, img_bounds[1].to_i, OverCompositeOp)
      end
      return image
    end

    def graph_gradients(bounds, gradients)
      img_bounds = bounds.split(",")
      img_x = img_bounds[2].to_i - img_bounds[0].to_i
      img_y = img_bounds[3].to_i - img_bounds[1].to_i
      backimg = Image.new(img_x, img_y)

      gradients.each do |grade|
        c1 = "rgb(#{grade["color1"]})"
        c2 = "rgb(#{grade["color2"]})"
        start = grade["start"].split(",")
        height ||= grade["height"]
        width ||= grade["width"]
        pos = grade["position"].split(",")
        op = grade["opacity"].to_f

        gimg_x = img_x
        gimg_y = img_y
        gimg_x = img_x if gimg_x == 0
        gimg_y = height if height
        gfill = GradientFill.new(start[0].to_i, start[1].to_i, start[2].to_i, start[3].to_i, c1, c2)
        gradimg = Image.new(gimg_x, gimg_y, gfill)
        backimg = backimg.dissolve(gradimg, op, 1.0, pos[0].to_i, pos[1].to_i)
      end

      return backimg
    end

    def agg_data(collection, field)
      results = {maxv: nil, minv: nil, count: nil, capture_min: nil, capture_max: nil}
      case collection
      when "raw"
        data = @platform.raw_data.captured_between(@start_date, @end_date).only(:capture_date, field)
      when "processed"
        data = @platform.processed_data.captured_between(@start_date, @end_date).only(:capture_date, field)
      else
        puts "Unknown collection name #{collection} in graph configuration!"
        raise
      end

      data.each do |datum|
        value = datum[field].to_f
        date = datum[:capture_date]
        unless value == @platform.no_data_value.to_f
          results[:maxv] = value if results[:maxv].nil? || value > results[:maxv]
          results[:minv] = value if results[:minv].nil? || value < results[:minv]
          results[:capture_min] = date if results[:capture_min].nil? || date < results[:capture_min]
          results[:capture_max] = date if results[:capture_max].nil? || date > results[:capture_max]
        end
      end
      results[:count] = data.count

      return results
    end

    private

    def num_round(data, roundnum)
      if roundnum == 0
        newdata = data.round
      else
        newdata = data.round(roundnum)
      end
      return newdata
    end

    def conv_units(data_units, units, data)
      newdata = data
      newdata = (data * 9)/5 + 32 if data_units == "cel" and units == "fahr"
      newdata = ((data - 32) * 5) / 9 if data_units == "fahr" and units == "cel"
      newdata = data * 3.2808 if data_units == "met" and units == "feet"
      newdata = data * 1.09 if data_units == "feet" and units == "met"
#      newdate = data.utc.to_i if units == "date"
      return newdata
    end
  end

  class GraphStyle
    attr_accessor :color, :fill_color, :profile_color, :fill_to, :line_size, :line_type, :text_size

    def initialize(style_object)
      self.color = "rgb(#{style_object["color"]})" if style_object["color"]
      self.fill_color = "rgb(#{style_object["fill_color"]})" if style_object["fill_color"]
      self.profile_color = "rgb(#{style_object["profile_color"]})" if style_object["profile_color"]

      self.fill_to ||= style_object["fill_to"]
      self.line_size ||= style_object["line_size"]
      self.line_type ||= style_object["line_type"]
      self.text_size ||= style_object["text_size"]
    end
  end
end