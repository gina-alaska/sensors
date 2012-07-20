# Draw background dividers on graph
module RvgGraph
  class Dividers
    def self.draw(bcord, data, agg, canvas)
      data["axis"].each do |axis|
        if axis["dividers"]
          divider_object = axis["dividers"]
          dstyle = Style.new(divider_object["style"])
          x_min = bcord.xmin
          x_max = bcord.xmax
          top = bcord.ymin
          bottom = bcord.ymax
          major_tics = divider_object["major"].to_i
          hard_min = axis["hard_min"]
          hard_max = axis["hard_max"]
          data_top = data["graph_top"]

          dmax = agg.maxval.to_f
          dmin = agg.minval.to_f
          dmin = hard_min unless hard_min.nil?
          dmax = hard_max unless hard_max.nil?
          hard_min = dmin if hard_min.nil?
          hard_max = dmax if hard_max.nil?

          # Find nice number range for axis tics/labels
          unless axis["label"]["units"] == "date"
            nice_range = Nicenum.calc(dmax - dmin, false)
            nice_tic_delta = Nicenum.calc(nice_range/(major_tics - 1), true).to_f
            nice_min = (dmin / nice_tic_delta).floor * nice_tic_delta
            nice_max = (dmax / nice_tic_delta).ceil * nice_tic_delta
            minor_delta = nice_tic_delta / minor_tics unless minor_tics.nil?
#              puts "nmin #{nice_min} nmax #{nice_max} delta #{nice_tic_delta}"
          else
            dmin = agg.capture_min.utc.to_i
            dmax = agg.capture_max.utc.to_i
            hard_max = dmax
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

#puts "nmin #{nice_min} nmax #{nice_max}"
          convert = CalcPosition.new(top, bottom, data_top, drange, x_max-x_min, 0)
          xdelta = convert.calc(nice_tic_delta, true)
#puts "xdelta #{xdelta}"
          # draw divider lines
          x_min.step(x_max, xdelta) do |x|
            puts "x - #{x} lsize #{dstyle.line_size}"
            canvas.line(x.to_i, top.to_i, x.to_i, bottom.to_i).styles( :stroke=>dstyle.color, :stroke_width=>dstyle.line_size, :stroke_dasharray=>dstyle.line_type)
          end
        end
      end
    end    
  end
end