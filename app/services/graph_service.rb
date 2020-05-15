# frozen_string_literal: true

class GraphService
  Point = Struct.new(:x, :y, :title)
  Result = Struct.new(:points, :date, :value, :max)

  MAX_ON_HEIGHT = 0.8 # max height of graph related to canvas
  IMMUNE_STATUS_INTERVAL = { bottom: 400, top: 1200 }.freeze

  def initialize(user)
    @user = user
  end

  def render_image
    kit = IMGKit.new(render_html, quality: 100, width: Graph.canvas_width, height: Graph.canvas_height)
    kit.stylesheets << stylesheet_path
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
      immune_status: immune_status_data,
      viral_load: viral_load_data,
      tredline: immune_status_tredline,
      years: years_points,
      immune_status_interval: immune_status_interval,
      date: [immune_status_data&.date, viral_load_data&.date].compact.max
    }
  end

  private

  attr_reader :user

  def render_html
    ActionController::Base.new.render_to_string(
      template: 'graphs/show',
      layout: false,
      locals: render_data
    )
  end

  def results_for(result_type)
    results = test_results.where(result_type: result_type)
    points = calculate_points(
      results: results,
      x_resolution: date_resolution,
      y_resolution: value_resolution(results)
    )
    Result.new(points, results.last&.date, results.last&.value, results&.pluck(:value)&.max)
  end

  def test_results
    @test_results ||= user.test_results.ordered
  end

  def immune_status_interval
    return [] if test_results.immune_status.empty?

    resolution = value_resolution(test_results.immune_status)
    [
      IMMUNE_STATUS_INTERVAL[:bottom] * resolution,
      IMMUNE_STATUS_INTERVAL[:top] * resolution
    ]
  end

  def calculate_points(results:, x_resolution:, y_resolution:)
    return [] if results.empty?

    min_date = results.pluck(:date).min
    results.map do |result|
      x_coord = (result.date - min_date) * x_resolution
      y_coord = result.value * y_resolution
      Point.new(x_coord.to_i, Graph.chart_height - y_coord.to_i)
    end
  end

  # NOTE: How many pixels in one day
  def date_resolution
    return @date_resolution if @date_resolution

    dates = test_results.pluck(:date)
    @date_resolution = Graph.chart_width / (dates.max - dates.min).to_f
  end

  def years_points
    dates = test_results.pluck(:date)
    years = dates.map(&:year).uniq[1..]
    all_years = (years.first..years.last).to_a
    all_years.map do |year|
      x_coord = (Date.new(year) - dates.min) * date_resolution
      Point.new(x_coord, 0, year)
    end
  end

  # NOTE: How many pixels in one point
  def value_resolution(results)
    return if results.empty?

    if results.take.immune_status?
      Graph.chart_height / (IMMUNE_STATUS_INTERVAL[:top] + 100).to_f
    else
      resolution_for_viral_load(results)
    end
  end

  def resolution_for_viral_load(results)
    max_value = results.pluck(:value).max
    denominator = max_value&.positive? ? max_value : 1
    Graph.chart_height / denominator.to_f
  end

  def stylesheet_path
    builder = Sprockets::Railtie.build_environment(Rails.application)
    asset = builder.find_asset('graph.css', base_path: Rails.application.root.to_s)
    Rails.root.join('public', 'assets', asset.digest_path)
  end
end
