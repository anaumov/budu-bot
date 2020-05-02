# frozen_string_literal: true

module TimeRange
  def self.today
    time = Time.zone.now
    (time.beginning_of_day..time.end_of_day)
  end
end
