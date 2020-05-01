# frozen_string_literal: true

class AdminController < ApplicationController
  before_action :authenticate_user!
  layout 'admin'

  def menu_items
    %w[messages]
  end
  helper_method :menu_items

  def page
    params[:page] || 1
  end
end
