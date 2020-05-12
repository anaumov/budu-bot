# frozen_string_literal: true

Point = Struct.new(:x, :y)

class GraphsController < ApplicationController
  def show
    return unless Rails.env.development?

    service = GraphService.new(user: user, width: 600, height: 300)
    render locals: service.render_data, layout: false
  end

  private

  def user
    @user ||= User.find(params[:id])
  end
end
