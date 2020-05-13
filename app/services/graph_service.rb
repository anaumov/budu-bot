# frozen_string_literal: true

class GraphService
  Point = Struct.new(:x, :y)
  Result = Struct.new(:points, :date, :value, :max)

  MAX_ON_HEIGHT = 0.8 # max height of graph related to canvas
  MAX_ON_WIDTH = 0.8 # max height of graph related to canvas
  IMMUNE_STATUS_INTERVAL = { bottom: 400, top: 1200 }.freeze

  def initialize(user:, width:, height:)
    @user = user
    @width = width
    @height = height
  end

  def render_image
    kit = IMGKit.new(render_html, quality: 100, width: 600, height: 400)
    kit.stylesheets << File.join(Rails.root, '/public/graph.css')
    kit.to_file("current_graph_for_#{user.id}.jpg")
  end

  def remove_file(file)
    File.delete(file.path) if !Rails.env.test? && File.exist?(file.path)
  end

  def render_data
    immune_status_data = results_for(:immune_status)
    viral_load_data = results_for(:viral_load)
    immune_status_tredline = TredlineService.perform(immune_status_data.points)

    {
      dimentions: Point.new(width, height),
      immune_status: immune_status_data,
      viral_load: viral_load_data,
      tredline: immune_status_tredline,
      immune_status_interval: immune_status_interval,
      date: [immune_status_data&.date, viral_load_data&.date].compact.max
    }
  end

  private

  attr_reader :user, :width, :height

  def render_html
    ActionController::Base.new.render_to_string(
      template: 'graphs/show',
      layout: false,
      locals: render_data
    )
  end

  def results_for(result_type)
    results = test_results.where(result_type: result_type)
    Result.new(points(results), results.last&.date, results.last&.value, results&.pluck(:value)&.max)
  end

  def test_results
    @test_results ||= user.test_results.ordered
  end

  def immune_status_interval
    return [] if test_results.immune_status.empty?

    resolution = value_resolution(test_results.immune_status)
    [IMMUNE_STATUS_INTERVAL[:bottom] * resolution, IMMUNE_STATUS_INTERVAL[:top] * resolution]
  end

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
    values.push(IMMUNE_STATUS_INTERVAL[:top]) if results.take&.immune_status?
    if values.count > 1 && values.any? { |v| !v.zero? }
      height * MAX_ON_HEIGHT / values.max.to_f
    else
      height * MAX_ON_HEIGHT
    end
  end
end
