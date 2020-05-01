# frozen_string_literal: true

class Message < ApplicationRecord
  scope :ordered, -> { order(id: :desc) }

  def self.build(slug, **args)
    message = find_by!(slug: slug)
    I18n.interpolate(message.text, **args)
  end
end
