# frozen_string_literal: true

class TestResult < ApplicationRecord
  belongs_to :user
  enum result_type: %i[viral_load immune_status]
  scope :ordered, -> { order(date: :asc) }

  def ru_result_type
    I18n.t(result_type, scope: %i[test_result result_type])
  end

  def dec_date
    I18n.l(date, format: '%d.%m.%Y')
  end

  def message_view
    "#{ru_result_type.capitalize} #{value} на #{dec_date}"
  end
end
