# frozen_string_literal: true

class TestResultsFactory
  SHORT_MATCHER = { 'в' => :viral_load, 'и' => :immune_status }.freeze
  FULL_MATCHER = {
    viral_load: %w[вн нагр вирус врус dy dbhec],
    immune_status: %w[ис иммун имун стат bc bvey]
  }.freeze

  def initialize(user, message)
    @user = user
    @message = message.strip.downcase
  end

  def create_test_result!
    test_result = user.test_results.find_or_initialize_by(result_type: result_type, date: parse_date)
    test_result.assign_attributes(value: parse_value, message: { text: message })
    test_result.save!
    test_result
  end

  private

  attr_reader :user, :message

  def result_type
    identity = message.match(/([\p{L}\s])+/)[0]&.strip
    if identity&.size == 1
      SHORT_MATCHER[identity]
    elsif identity.present?
      FULL_MATCHER.find { |_, value| value.any? { |el| identity.include?(el) } }&.first
    end || (raise StandardError)
  end

  def parse_value
    message.gsub(/\p{L}/, '').strip.split.first
  end

  def parse_date
    date = message.split.last
    if date&.size == 8
      day, month, year = date.split(/[\.\-\:]/)
      Date.parse("#{day}.#{month}.20#{year}")
    elsif date.present?
      Date.parse(date)
    end
  rescue Date::Error
    Date.today
  end
end
