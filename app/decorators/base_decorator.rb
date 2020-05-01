# frozen_string_literal: true

class BaseDecorator
  include Rails.application.routes.url_helpers
  include ActionView::Helpers::UrlHelper

  attr_reader :object

  def initialize(object)
    @object = object
  end

  def method_missing(method_name, *args, &block)
    object.public_send(method_name, *args)
  rescue NoMethodError
    super
  end

  def respond_to_missing?(method_name, *args)
    object.respond_to?(method_name, args)
  end
end
