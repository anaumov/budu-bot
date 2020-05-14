# frozen_string_literal: true

class Graph
  def self.canvas_width
    630
  end

  def self.canvas_height
    350
  end

  def self.header_height
    canvas_height - graph_height
  end

  def self.graph_height
    254
  end

  def self.chart_height
    (graph_height * 0.92).ceil
  end

  def self.chart_width
    (canvas_width * 0.86).ceil # 86%
  end
end
