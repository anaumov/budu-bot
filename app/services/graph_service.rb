# frozen_string_literal: true

Point = Struct.new(:x, :y)

class GraphService
  MAX_ON_HEIGHT = 0.8 # max height of graph related to canvas
  MAX_ON_WIDTH = 0.8 # max height of graph related to canvas

  def initialize(test_results:, width:, height:)
    @test_results = test_results
    @width = width
    @height = height
  end

  def render_image(result_type)
    @result_type = result_type
    controller = ActionController::Base.new
    html = controller.render_to_string(template: 'graphs/show', locals: { points: points })
    kit = IMGKit.new(html, quality: 50)
    kit.to_file("#{result_type}_#{results.id}.jpg")
  end

  def remove_file(file)
    File.delete(file.path) if !Rails.env.test? && File.exist?(file.path)
  end

  def immune_status
    points(test_results.immune_status)
  end

  def viral_load
    # points(test_results(:viral_load))
    []
  end

  private

  attr_reader :test_results, :width, :height
  def points(results)
    return [] if results.empty?

    min_date = results.pluck(:date).min
    x_resolution = day_resolution(results)
    y_resolution = value_resolution(results)
    results.map do |result|
      x_coord = (result.date - min_date) * x_resolution
      y_coord = result.value * y_resolution
      Point.new(x_coord.to_i, height - y_coord.to_i)
    end
  end

  # NOTE: How many pixels in one day
  def day_resolution(results)
    dates = results.pluck(:date)
    if dates.count > 1
      width * MAX_ON_WIDTH / (dates.max - dates.min).to_f
    else
      width * MAX_ON_WIDTH / 2
    end
  end

  # NOTE: How many pixels in one point
  def value_resolution(results)
    values = results.pluck(:value)
    if values.count > 1 && values.any? { |v| !v.zero? }
      height * MAX_ON_HEIGHT / values.max.to_f
    else
      height * MAX_ON_HEIGHT
    end
  end
end
