# Collect and process graph object style information
module RvgGraph
  class Style
    attr_accessor :color, :fill_color, :profile_color, :fill_to, :line_size, :line_type, :text_size, :bg_color

    def initialize(style_object)
      self.color = "rgb(#{style_object["color"]})" if style_object["color"]
      self.fill_color = "rgb(#{style_object["fill_color"]})" if style_object["fill_color"]
      self.profile_color = "rgb(#{style_object["profile_color"]})" if style_object["profile_color"]
      self.bg_color = "rgb(#{style_object["graph_bg_color"]})" if style_object["graph_bg_color"]

      self.fill_to ||= style_object["fill_to"]
      self.line_size ||= style_object["line_size"]
      linetype ||= style_object["line_type"]
      if linetype
        lt = linetype.split(",")
        self.line_type = [lt[0].to_i, lt[1].to_i]
      end
      self.text_size ||= style_object["text_size"]
    end
  end
end