# frozen_string_literal: true

class GraphService
  def initialize(user)
    @user = user
  end

  def render_image
    GraphRenderer.new(graph_data).image
  end

  def graph_data
    GraphDataService.perform(user)
  end

  def remove_file(file)
    File.delete(file.path) if !Rails.env.test? && File.exist?(file.path)
  end

  private

  attr_reader :user
end
