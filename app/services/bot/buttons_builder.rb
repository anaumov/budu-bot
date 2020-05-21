# frozen_string_literal: true

module Bot
  class ButtonsBuilder
    def self.hour_buttons(from, to)
      new.hour_buttons(from, to)
    end

    def hour_buttons(from, to)
      buttons = [[{ text: Button.get(:earlier), callback_data: "hour_buttons:#{from - 6}..#{from - 1}" }]]
      buttons += buttons_by_hours(from, to)
      buttons << [{ text: Button.get(:later), callback_data: "hour_buttons:#{to + 1}..#{to + 6}" }]
      buttons
    end

    private

    def buttons_by_hours(from, to)
      hour_to_button = ->(hour) { [{ text: "#{hour}:00", callback_data: "set_notification:#{hour}" }] }
      build_range(from, to).to_a.map(&hour_to_button)
    end

    def build_range(from, to)
      (from..to).to_a.map do |hour|
        hour = hour % 24
        if hour > 23
          hour - 24
        elsif hour.negative?
          hour + 24
        else
          hour
        end
      end
    end
  end
end
