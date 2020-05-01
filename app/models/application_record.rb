# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def decorate!
    decorator_class = "#{self.class.name}Decorator".safe_constantize || BaseDecorator
    decorator_class.new(self)
  end
end
