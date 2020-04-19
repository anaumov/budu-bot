# frozen_string_literal: true

class TestResult < ApplicationRecord
  belongs_to :user
  enum result_type: %i[viral_load immune_status]

  def ru_result_type
    I18n.t(result_type, scope: %i[test_result result_type])
  end
end
