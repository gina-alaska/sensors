# Collect and process graph object style information
module RvgGraph
  class GraphStyle
    attr_accessor :color, :fill_color, :profile_color, :fill_to, :line_size, :lt_diva, :lt_divb, :text_size, :bg_color

    def initialize(style_object)
      self.color = "rgb(#{style_object["color"]})" if style_object["color"]
      self.fill_color = "rgb(#{style_object["fill_color"]})" if style_object["fill_color"]
      self.profile_color = "rgb(#{style_object["profile_color"]})" if style_object["profile_color"]
      self.bg_color = "rgb(#{style_object["graph_bg_color"]})" if style_object["graph_bg_color"]

      self.fill_to ||= style_object["fill_to"]
      self.line_size ||= style_object["line_size"]
      line_type ||= style_object["line_type"]
      if line_type
        lt = line_type.split(",")
        self.lt_diva = lt[0].to_i
        self.lt_divb = lt[1].to_i
      end
      self.text_size ||= style_object["text_size"]
    end
  end
end