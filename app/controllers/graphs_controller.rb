# frozen_string_literal: true

Point = Struct.new(:x, :y)

class GraphsController < ApplicationController
  def show
    return unless Rails.env.development?

    service = GraphService.new(test_results: test_results, width: canva_size.x, height: canva_size.y)
    render locals: {
      dimentions: canva_size,
      date: test_results.last.date,
      immune_status: {
        value: test_results.immune_status.last.value,
        points: service.immune_status
      },
      viral_load: service.viral_load
    }
  end

  private

  def canva_size
    Point.new(600, 400)
  end

  def test_results
    @test_results ||= User.find(params[:id]).test_results.order(date: :asc)
  end
end
