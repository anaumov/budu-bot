# frozen_string_literal: true

class TestResultsFactory
  RESULT_MATCHES = { viral_load: %w[вн нагр вирус врус dy dbhec], immune_status: %w[ис иммун имун стат bc bvey] }.freeze

  def initialize(user, message)
    @user = user
    @message = message.strip.downcase
  end

  def create_test_result!
    return if result_type.nil?

    test_result = user.test_results.find_or_initialize_by(result_type: result_type, date: parse_date)
    test_result.assign_attributes(value: parse_value, message: { text: message })
    test_result.save!
    test_result
  end

  private

  attr_reader :user, :message

  def result_type
    @result_type ||= RESULT_MATCHES.find { |_, value| value.any? { |el| message.include?(el) } }&.first
  end

  def parse_value
    message.split.second_to_last.to_i
  end

  def parse_date
    date = message.split.last
    if date.size == 8
      day, month, year = date.split(/[\.\-\:]/)
      Date.parse("#{day}.#{month}.20#{year}")
    else
      Date.parse(date)
    end
  end
end
