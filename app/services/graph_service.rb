# frozen_string_literal: true

Point = Struct.new(:x, :y)

class GraphService
  GRAPH_WIDTH = 600
  GRAPH_HEIGHT = 400

  def initialize(user)
    @user = user
  end

  def render_image(result_type)
    @result_type = result_type
    controller = ActionController::Base.new
    html = controller.render_to_string(template: 'graphs/show', locals: { points: points })
    kit = IMGKit.new(html, quality: 50)
    kit.to_file("#{result_type}_#{user.id}.jpg")
  end

  def remove_file(file)
    File.delete(file.path) if !Rails.env.test? && File.exist?(file.path)
  end

  def build_points(result_type)
    @result_type = result_type
    points
  end

  private

  attr_reader :user, :result_type

  # rubocop:disable Metrics/AbcSize
  def points
    return [] if results.empty?

    dates = results.pluck(:date)
    day_resolution = (dates.count > 1 ? GRAPH_WIDTH * 0.9 / (dates.max - dates.min).to_f : GRAPH_WIDTH * 0.9 / 2)
    values = results.pluck(:value)
    has_non_zero = (values.uniq.count == 1 && !values.sample.zero?)
    value_resolution = (values.count > 1 && has_non_zero ? GRAPH_HEIGHT * 0.9 / values.max.to_f : GRAPH_HEIGHT * 0.9)
    results.map do |result|
      x_coord = (result.date - dates.min) * day_resolution
      y_coord = result.value * value_resolution
      Point.new(x_coord.to_i, GRAPH_HEIGHT - y_coord.to_i)
    end
  end
  # rubocop:enable Metrics/AbcSize

  def results
    user.test_results.where(result_type: result_type).order(:date)
  end
end
