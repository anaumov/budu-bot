# frozen_string_literal: true

class TestResultsFactory
  def initialize(user)
    @user = user
  end

  def create_from_message(message)
    result_type, value, raw_date = message['text'].split(' ')
    user.test_results.create!(
      result_type: guess_test_result(result_type),
      value: value.to_i,
      date: Date.parse(raw_date),
      message: message
    )
  end

  private

  attr_reader :user

  def guess_test_result(result_type)
    result_type = result_type.strip.downcase
    {
      viral_load: %w[вн нагр вирус врус dy dbhec],
      immune_status: %w[ис иммун имун стат bc bvey]
    }.find { |_, value| value.any? { |el| result_type.include?(el) } }.first
  end
end
