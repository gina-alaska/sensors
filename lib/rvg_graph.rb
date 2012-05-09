#
# graphmain object
#

module Rvg_graph
  class Massgraph
    attr_accessor :config, :template, :date, :graph_data, :database, :title

    def initialize(config_file, template_file)
      @config = YAML.load_file(config_file)
      @template = YAML.load_file(template_file)
      parse_config
      @canvas = RVG.new(@template["graph"]["x_size"],
           @template["graph"]["y_size"])
      @canvas.background_image =
          Magick::Image.read(@template["graph"]["background"]).first
    end

    def save(filename)
      @canvas.draw.write filename
    end

    def dbconnect(db_object)
      host = db_object["host"]
      name = db_object["name"]
      login = db_object["login"]
      pass = db_object["pass"]

      @database = PGconn.new(host, nil, nil, nil, name, login, pass)
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
      start_day = self.date["day_start"] - self.date["days"]
      end_day = self.date["day_start"]
      datef = "data#{self.date["day_field"]}"

      data_object.each do |data|
        item = data["item"]
        data_template = @template["graph_data"][item]
        color = "rgb(#{data_template["color"]})"
        data_field = data["data_field"]
        dbtable = self.config["database"]["data_table"]
        dbfield = "data#{data_field}"
        top = data_template["top"].to_f
        bottom = data_template["bottom"].to_f
        line_width = data_template["width"].to_i
        mark_high = data_template["mark_high"].to_i
        mark_low = data_template["mark_low"].to_i

        dbcomm = "select max(#{dbfield}::float),
             min(#{dbfield}::float),
             count(#{dbfield}) from #{dbtable} where
             #{datef}::integer >= #{start_day} and
             #{datef}::integer <= #{end_day} and
             #{dbfield}::float > -9999;"
        result = @database.exec(dbcomm)
        maxval = result.getvalue(0,0).to_f
        minval = result.getvalue(0,1).to_f
        count = result.getvalue(0,2).to_f
        data_template["maxval"] = maxval
        data_template["minval"] = minval
        data_top = data_template["data_top"]

        hard_min ||= @template["y_axis"][item]["y_set"]["hard_min"]
        hard_max ||= @template["y_axis"][item]["y_set"]["hard_max"]

        savemax = maxval
        savemin = minval
        if !hard_min.nil?
          addjustmin = minval - hard_min
          minval = hard_min
        else
          addjustmin = 0
        end
        maxval = hard_max if !hard_max.nil?

        oldrange = maxval - minval

        dbcomm = "select #{dbfield}::float from #{dbtable} where
             #{datef}::integer >= #{start_day} and
             #{datef}::integer <= #{end_day} and
             #{dbfield}::float > -9999;"
        result = @database.exec(dbcomm)

        ratiox = (x_max - x_min)/count
        newrange = bottom - top
        newx = x_min
        newy = 0

        if !data_template["fill_color"].nil?
          fill_color = "rgb(#{data_template["fill_color"]})"
          fill_to = data_template["fill_to"]
          rarray = result.field_values(dbfield)
          firstnum = rarray.first.to_f
          if data_top == "down"
            firsty = (((firstnum - minval) * newrange) / oldrange) + top
          else
            firsty = bottom - (((firstnum - minval) * newrange) / oldrange)
          end
          lastnum = rarray.last.to_f
          if data_top == "down"
            lasty = (((lastnum - minval) * newrange) / oldrange) + top
          else
            lasty = bottom - (((lastnum - minval) * newrange) / oldrange)
          end

          path = "M "
          result.each do |row|
            vdata = row[dbfield].to_f
            next if vdata == -9999
            if data_top == "down"
              newy = (((vdata - minval + addjustmin) * newrange) / oldrange) + top
            else
              newy = bottom - (((vdata - minval + addjustmin) * newrange) / oldrange)
            end
            path += "#{newx.to_i} #{newy.to_i} L "
            newx += ratiox
          end
          if fill_to == "top"
            path += "#{x_max.to_i} #{lasty.to_i} L #{x_max.to_i} #{top.to_i}
            L #{x_min.to_i} #{top.to_i} L #{x_min.to_i} #{firsty.to_i} z"
          else
            path += "#{x_max.to_i} #{lasty.to_i} L #{x_max.to_i} #{bottom.to_i}
                 L #{x_min.to_i} #{bottom.to_i} L #{x_min.to_i} 
                 #{firsty.to_i} z"
          end
          @canvas.path(path).styles(:stroke=>fill_color, :fill=>fill_color,
              :stroke_width=>"0.8")
        end

        savx = newx = x_min
        savy = newy = 0

        result.each do |row|
          vdata = row[dbfield].to_f
          if vdata == -9999
            savy = 0
            next
          end
          
          newx += ratiox
          if data_top == "down"
            newy = (((vdata - minval + addjustmin) * newrange) / oldrange) + top
          else
            newy = bottom - (((vdata - minval + addjustmin) * newrange) / oldrange)
          end

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
            newx = x_min
            next
          else
            @canvas.line(savx, savy, newx, newy).styles(:stroke=>color, 
               :stroke_width=>line_width, :stroke_linecap=>"round")
          end
          savx = newx
          savy = newy
        end
      end
    end

    def draw_border(border_object)
      bcord = @template["graph"]["graph_bounds"].split(",")
      color = "rgb(#{border_object["color"]})"
      line = border_object["line_size"]
      fill_color = "rgb(#{@template["graph"]["background_color"]})"

      # Clean up border area
      (1..4).each do |num|
        numt = num*2
        @canvas.rect((bcord[2].to_i-bcord[0].to_i)+numt,
           (bcord[3].to_i-bcord[1].to_i)+numt,
           bcord[0].to_i-num, bcord[1].to_i-num).styles(:stroke=>fill_color,
           :stroke_width=>line, :fill_opacity=>0)
      end
 
      # Draw border
      @canvas.rect(bcord[2].to_i-bcord[0].to_i, bcord[3].to_i-bcord[1].to_i,
           bcord[0].to_i, bcord[1].to_i).styles(:stroke=>color,
           :stroke_width=>line, :fill_opacity=>0)

      # Build break lines
      blbox = border_object["break_line"].split(",")
      y_pos = blbox[0].to_i
      skew = blbox[3].to_i
      width = blbox[1].to_i
      thick = blbox[2].to_i
      break_line = RVG::Group.new do |bline|
        bline.rect(width,thick,0,0).styles(:fill=>fill_color,
            :stroke=>fill_color)
        bline.line(0,0,width,0).styles(:stroke=>color, :stroke_width=>line+0.5)
        bline.line(0,thick,width,thick).styles(:stroke=>color,
            :stroke_width=>line+0.5)
      end

      # Draw break lines
      @canvas.use(break_line, bcord[0].to_i,
          y_pos).translate(-width/2).skewY(skew)
      @canvas.use(break_line, bcord[2].to_i,
          y_pos).translate(-width/2).skewY(skew)
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

    private

    def parse_config
      self.config = @config
      self.template = @template
      self.title = @template["graph"]["title"] if !@template["graph"]["title"].nil?
      self.date = @template["date"] if !@template["date"].nil?
      self.graph_data = @config["graph_data"] if !@config["graph_data"].nil?
      self.database = @config["database"] if !@config["database"].nil?
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
  end
end

