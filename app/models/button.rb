# frozen_string_literal: true

class Button
  BUTTONS =  {
    earlier: '⬆️',
    later: '⬇️',
    notifications_setup: '🔔',
    results_instruction: '🔬',
    morning: 'Утром',
    evening: 'Вечером',
    cancel: '❌'
  }.freeze

  def self.get(key)
    BUTTONS[key]
  end
end
