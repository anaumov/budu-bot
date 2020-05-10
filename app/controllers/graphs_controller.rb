# frozen_string_literal: true

Point = Struct.new(:x, :y)

class GraphsController < ApplicationController
  def show
    return unless Rails.env.development?

    service = GraphService.new(user: user, width: canva_size.x, height: canva_size.y)
    result = service.render_data
    render locals: {
      dimentions: canva_size,
      immune_status: result[:immune_status],
      viral_load: result[:viral_load],
      tredline: result[:tredline],
      date: [result[:immune_status].date, result[:viral_load].date].max
    }, layout: false
  end

  private

  def canva_size
    Point.new(600, 400)
  end

  def user
    @user ||= User.find(params[:id])
  end
end
