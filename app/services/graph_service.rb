# frozen_string_literal: true

class GraphService
  Point = Struct.new(:x, :y)
  Result = Struct.new(:points, :date, :value)
  Tredilne = Struct.new(:a, :b)

  MAX_ON_HEIGHT = 0.8 # max height of graph related to canvas
  MAX_ON_WIDTH = 0.8 # max height of graph related to canvas

  def initialize(user:, width:, height:)
    @user = user
    @width = width
    @height = height
  end

  def render_image
    controller = ActionController::Base.new
    html = controller.render_to_string(template: 'graphs/show', locals: { points: points })
    kit = IMGKit.new(html, quality: 50)
    kit.to_file("#{result_type}_#{results.id}.jpg")
  end

  def remove_file(file)
    File.delete(file.path) if !Rails.env.test? && File.exist?(file.path)
  end

  def render_data
    immune_status_data = results_for(:immune_status)
    {
      immune_status: immune_status_data,
      viral_load: results_for(:viral_load),
      tredline: calculate_tredline(immune_status_data.points)
    }
  end

  private

  attr_reader :user, :width, :height

  def results_for(result_type)
    results = test_results.where(result_type: result_type)
    Result.new(points(results), results.last.date, results.last.value)
  end

  def test_results
    @test_results ||= user.test_results.ordered
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
    if values.count > 1 && values.any? { |v| !v.zero? }
      height * MAX_ON_HEIGHT / values.max.to_f
    else
      height * MAX_ON_HEIGHT
    end
  end

  # Formula https://math.stackexchange.com/questions/204020
  def calculate_tredline(points)
    a = numerator(points) / denominator(points).to_f
    Tredilne.new(a, calculate_b(points, a))
  end

  def denominator(points)
    denominator = points.size * points.map { |p| p.x**2 }.sum
    denominator - points.map(&:x).sum**2
  end

  def numerator(points)
    numerator = points.size * points.map { |p| p.x * p.y }.sum
    numerator - points.map(&:x).sum * points.map(&:y).sum
  end

  def calculate_b(points, a) # rubocop:disable Naming/MethodParameterName
    numerator = points.map(&:y).sum - a * points.map(&:x).sum
    numerator / points.size.to_f
  end
end
