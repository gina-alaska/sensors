#
# Ginagraph object
#
require 'rvg/rvg'

module RvgGraph
  class Ginagraph
    include Magick
    attr_accessor :template

    def initialize(slug, graph, starts_at, ends_at)
      @platform = Platform.where(slug: slug).first
      @template = Psych.load(graph.config)
      parse_config
      @canvas = RVG.new(@template["graph"]["width"],
           @template["graph"]["height"])
      background_img = gen_background_img(@template["graph"])
      @canvas.background_image = background_img
      @start_date = starts_at
      @end_date = ends_at
    end

    def save(filename)
      @canvas.draw.write filename
    end

    def draw_title
      bcord = @template["graph"]["graph_bounds"].split(",")
      @canvas.text((bcord[2].to_i-bcord[0].to_i)/2+bcord[0].to_i,
          bcord[1].to_i-10, self.title).styles(
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
        marks = data["mark"].split(",")
        mark_high = marks[1].to_i if marks[0] == "high"
        mark_low = marks[1].to_i if marks[0] == "low"
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
            puts "newx #{newx}"
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
          puts "newx #{newx}"
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
      end
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

    def draw_x_axis(xaxis_object)
      bcord = @template["graph"]["graph_bounds"].split(",")
      x_min = bcord[0].to_i
      x_max = bcord[2].to_i
      base_top = bcord[1].to_i
      base_bottom = bcord[3].to_i
      line_size = xaxis_object["line_size"]
      color = "rgb(#{xaxis_object["color"]})"
      minor_tic = xaxis_object["minor_tic_height"]
      major_tic_h = xaxis_object["major_tic_height"]
      major_tic = xaxis_object["major_tics"]
      label_offset = xaxis_object["label_offset"]
      label_size = xaxis_object["label_size"]

      # calculate tics
      days = self.date["days"]
      width = x_max - x_min
      day_width = (width/days).to_i
      day_start = self.date["day_start"] - days
      
      # draw bottom x-axis
      mtic = 1 # keep track of the major tics
      if !base_bottom.nil?
        @canvas.line(x_min, base_bottom, x_max, base_bottom).styles(
             :stroke_width=>line_size, :stroke=>color)
        x_min.step(x_max, day_width) do |x|
          if mtic == major_tic
            @canvas.line(x, base_bottom, x, base_bottom-major_tic_h).styles(
               :stroke_width=>line_size, :stroke=>color)
            mtic = 1
            # Add in label
            day = day_start+(x/day_width)
            year = self.date["year"]
            odate = Date.ordinal(year, day).strftime("%d %b")
            @canvas.text(x, base_bottom+label_offset, odate).styles(
                :fill=>color, :font_size=>label_size.to_i,
                :font_family=>'Verdana', :text_anchor=>"middle")
          else
            @canvas.line(x, base_bottom, x, base_bottom-minor_tic).styles(
               :stroke_width=>line_size, :stroke=>color)
            mtic += 1
          end
        end
      end

      # draw top x-axis
      mtic = 1
      if !base_top.nil?
        @canvas.line(x_min, base_top, x_max, base_top).styles(
             :stroke_width=>line_size)
        x_min.step(x_max, day_width) do |x|
          if mtic == major_tic
            @canvas.line(x, base_top, x, base_top+major_tic_h).styles(
               :stroke_width=>line_size, :stroke=>color)
            mtic = 1
          else
            @canvas.line(x, base_top, x, base_top+minor_tic).styles(
               :stroke_width=>line_size, :stroke=>color)
            mtic += 1
          end
        end
      end
    end

    def draw_yaxis(data_object)
      data_object.each do |data|
        item = data["item"]
        graph_set = @template["graph_data"][item]
        yaxis_set = @template["y_axis"][item]["y_set"]
        data_units = data["units"]

        # Draw y-axis
        if !@template["y_axis"][item]["left"].nil?
          left_set = @template["y_axis"][item]["left"]
          do_y_axis(left_set, graph_set, "left", yaxis_set, data_units)
        end
        if !@template["y_axis"][item]["right"].nil?
          right_set = @template["y_axis"][item]["right"]
          do_y_axis(right_set, graph_set, "right", yaxis_set, data_units)
        end
      end
    end

    def do_y_axis(axis_set, graph_set, side, yaxis_set, data_units)
      top = graph_set["top"]
      bottom = graph_set["bottom"]
      maxval = graph_set["maxval"]
      bcord = @template["graph"]["graph_bounds"].split(",")
      numdiv = axis_set["numdiv"].to_i
      tic_size = axis_set["tic_size"].to_i
      tic_label_size = axis_set["tic_label_size"].to_i
      tic_label_offset = axis_set["tic_label_offset"].to_i
      tic_label_round = axis_set["round"].to_i
      label = axis_set["label"]
      label_size = axis_set["label_size"]
      label_offset = axis_set["label_offset"].to_i
      label_ypos = axis_set["label_ypos"].to_i

      x_min = bcord[0].to_i
      x_max = bcord[2].to_i
      color ||= "rgb(#{yaxis_set["color"]})"
      direction ||= yaxis_set["direction"]
      skip ||= yaxis_set["skip"]
      hard_min = yaxis_set.nil? ? nil : yaxis_set["hard_min"]
      hard_max ||= yaxis_set["hard_max"]
      
      if hard_min.nil?
        minval = graph_set["minval"]
      else
        minval = hard_min
      end

      if hard_max.nil?
        maxval = graph_set["maxval"]
      else
        maxval = hard_max
      end

      data_range = maxval - minval
      graph_range = bottom - top
      graph_step = graph_range/numdiv
      data_step = num_round((data_range.to_f/numdiv.to_f), tic_label_round)
      tdata = num_round(minval, tic_label_round)

      # Draw Labels
      if side == "left"
        y_pos = top + label_ypos
        x_pos = x_min - label_offset
        @canvas.text(x_pos, y_pos, label).styles(:fill=>color,
            :font_size=>label_size.to_i, :font_family=>'Verdana',
            :text_anchor=>'end')
      else
        y_pos = top + label_ypos
        x_pos = x_max + label_offset
        @canvas.text(x_pos, y_pos, label).styles(:fill=>color,
            :font_size=>label_size.to_i, :font_family=>'Verdana',
            :text_anchor=>'start')
      end
   
      # Draw y-axis'
      if direction == "top"
        bottom.step(top, -graph_step) do |y|
          if !skip.nil? && y == bottom
            tdata = num_round(tdata += data_step, tic_label_round)
            next
          end
          if side == "left"
            units = axis_set["units"]
            @canvas.line(x_min, y, x_min+tic_size, y).styles(:fill=>color)
            if units != data_units
              dtext = conv_units(data_units, units, tdata)
            else
              dtext = tdata
            end
            @canvas.text(x_min-tic_label_offset, y,
                sprintf("%0.#{tic_label_round}f", dtext)).styles(
                :fill=>color, :font_size=>tic_label_size.to_i,
                :font_family=>'Verdana', :text_anchor=>'end',
                :baseline_shift=>-((tic_label_size-2)/2))
            tdata = num_round(tdata += data_step, tic_label_round)
          else
            units = axis_set["units"]
            @canvas.line(x_max, y, x_max-tic_size, y).styles(:fill=>color)
            if units != data_units
              dtext = conv_units(data_units, units, tdata)
            else
              dtext = tdata
            end
            @canvas.text(x_max+tic_label_offset, y,
                sprintf("%0.#{tic_label_round}f", dtext)).styles(
                :fill=>color, :font_size=>tic_label_size.to_i,
                :font_family=>'Verdana', :text_anchor=>'start',
                :baseline_shift=>-((tic_label_size-2)/2))
            tdata = num_round(tdata += data_step, tic_label_round)
          end
        end
      else
        top.step(bottom, graph_step) do |y|
          if !skip.nil? && y == top
            tdata = num_round(tdata += data_step, tic_label_round)
            next
          end
          if side == "left"
            units = axis_set["units"]
            @canvas.line(x_min, y, x_min+tic_size, y).styles(:fill=>color)
            if units != data_units
              dtext = conv_units(data_units, units, tdata)
            else
              dtext = tdata
            end
            @canvas.text(x_min-tic_label_offset, y,
                sprintf("%0.#{tic_label_round}f", dtext)).styles(
                :fill=>color, :font_size=>tic_label_size.to_i,
                :font_family=>'Verdana', :text_anchor=>'end',
                :baseline_shift=>-((tic_label_size-2)/2))
            tdata = num_round(tdata += data_step, tic_label_round)
          else
            units = axis_set["units"]
            @canvas.line(x_max, y, x_max-tic_size, y).styles(:fill=>color)
            if units != data_units
              dtext = conv_units(data_units, units, tdata)
            else
              dtext = tdata
            end
            @canvas.text(x_max+tic_label_offset, y,
                sprintf("%0.#{tic_label_round}f", dtext)).styles(
                :fill=>color, :font_size=>tic_label_size.to_i,
                :font_family=>'Verdana', :text_anchor=>'start',
                :baseline_shift=>-((tic_label_size-2)/2))
            tdata = num_round(tdata += data_step, tic_label_round)
          end
        end
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
      results = {maxv: nil, minv: nil, count: nil}
      case collection
      when "raw"
        data = @platform.raw_data.captured_between(@start_date, @end_date).only(field)
      when "processed"
        data = @platform.processed_data.captured_between(@start_date, @end_date).only(field)
      else
        puts "Unknown collection name #{collection} in graph configuration!"
        raise
      end

      data.each do |datum|
        value = datum[field].to_f
        unless value == @platform.no_data_value.to_f
          results[:maxv] = value if results[:maxv].nil? || value > results[:maxv]
          results[:minv] = value if results[:minv].nil? || value < results[:minv]
        end
      end
      results[:count] = data.count

      return results
    end

    private

    def parse_config
      self.template = @template
      #self.title = @template["graph"]["title"] unless @template["graph"]["title"].nil?
      #puts @template.graph_data
      #self.graph_data = @template["graph_data"] unless @template["graph_data"].nil?
    end

    def num_round(data, roundnum)
      if roundnum == 0
        newdata = data.round
      else
        newdata = data.round(roundnum)
      end
      return newdata
    end

    def conv_units(data_units, units, data)
      newdata = (data * (9/5)) + 32 if data_units == "cel" and units == "far"
      newdata = (data - 32) * (5/9) if data_units == "far" and units == "cel"
      newdata = data * 3.2808 if data_units == "met" and units == "feet"
      newdata = data * 1.09 if data_units == "feet" and units == "met"
      return newdata
    end

    def axis_scale

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