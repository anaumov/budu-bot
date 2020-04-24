# frozen_string_literal: true

Point = Struct.new(:x, :y)

class GraphsController < ApplicationController
  def show
    return unless Rails.env.development?

    user = User.find(params[:id])
    service = GraphService.new(user)
    render locals: { dimentions: Point.new(x: 600, y: 400), points: service.build_points(graph_type) }
  end

  private

  def graph_type
    params[:graph_type] || :viral_load
  end
end
