# frozen_string_literal: true

class GraphDataService
  Result = Struct.new(:points, :date, :value, :max)

  MAX_ON_HEIGHT = 0.8 # max height of graph related to canvas
  IMMUNE_STATUS_INTERVAL = { bottom: 400, top: 1200 }.freeze

  def self.perform(user)
    new(user).perform
  end

  def initialize(user)
    @user = user
  end

  def perform
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
      x_coord = (result.date - min_date).to_i * x_resolution
      y_coord = result.value * y_resolution
      Point.new(x_coord.to_i, Graph.chart_height - y_coord.to_i)
    end
  end

  # NOTE: How many pixels in one day
  def date_resolution
    return @date_resolution if @date_resolution

    dates = test_results.pluck(:date)
    @date_resolution = if (dates.max - dates.min).zero?
                         0
                       else
                         Graph.chart_width / (dates.max - dates.min).to_f
                       end
  end

  def years_points
    dates = test_results.pluck(:date)
    get_years(dates).map do |year|
      x_coord = (Date.new(year) - dates.min) * date_resolution
      Point.new(x_coord, 0, year)
    end
  end

  def get_years(dates)
    years = dates.map(&:year).uniq
    if years.size == 1
      [years.first + 1]
    elsif years.size == 2
      [years.last, years.last + 1]
    else
      (years.second..years.last).to_a
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
end
