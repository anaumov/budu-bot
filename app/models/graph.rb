# frozen_string_literal: true

class Graph
  def self.canvas_width
    630 * 2
  end

  def self.canvas_height
    350 * 2
  end

  # NOTE: use as html font-size
  def self.base
    canvas_width / 63
  end

  def self.header_height
    canvas_height - graph_height
  end

  def self.graph_height
    (canvas_height * 0.73).ceil
  end

  def self.chart_height
    (graph_height * 0.95).ceil
  end

  def self.chart_width
    (canvas_width * 0.86).ceil # 86%
  end
end
