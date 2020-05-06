# frozen_string_literal: true

FactoryBot.define do
  factory :test_result do
    user
    value { 10 }
    result_type { :immune_status }
    date { Date.today }
  end
end
