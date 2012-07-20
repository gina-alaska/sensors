# Label text helper methods
module RvgGraph
  class LabelHelpers
    class << self
      def format(text, round)
        ntext = text
        unless text.is_a? String
          ntext = sprintf("%0.#{round}f", text)
        end
        return ntext
      end

      def middle(label)
        temp = label["text"].split("\n")
        height = (temp.length * label["size"]) / 2
      end

      def conv_units(data_units, units, data)
        newdata = data
        newdata = (data * 9)/5 + 32 if data_units == "cel" and units == "fahr"
        newdata = ((data - 32) * 5) / 9 if data_units == "fahr" and units == "cel"
        newdata = data * 3.28083989 if data_units == "met" and units == "feet"
        newdata = data * 0.3048 if data_units == "feet" and units == "met"
        return newdata
      end
    end
  end
end