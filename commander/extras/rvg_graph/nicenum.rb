# Calculate nice number ranges for graph axis
module RvgGraph
  class Nicenum
    # Thanks Heckbert!
    def self.calc(range, round)
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

    # Floor the date to the closest whole ammount specified.
    def self.date_floor(date, floor)
      case floor
      when "hour"
        newdate = date.change(:sec => 0)
      when "day"
        newdate = date.change(:min => 0)
      when "week"
        newdate = date.beginning_of_day
      when "month"
        newdate = date.beginning_of_week
      when "year"
        newdate = date.beginning_of_month
      else
        puts "Unknown floor #{floor} in date_floor function!"
        raise
      end

      return newdate
    end
  end
end