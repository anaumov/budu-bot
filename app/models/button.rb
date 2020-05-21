# frozen_string_literal: true

class Button
  BUTTONS =  {
    earlier: '⬆️',
    later: '⬇️',
    notifications_setup: 'Настроить 🔔',
    results_instruction: 'Отправить 📈',
    turn_off_notifications: 'Отключить 🔔',
    cancel: '❌'
  }.freeze

  def self.get(key)
    BUTTONS[key]
  end
end
