# frozen_string_literal: true

class MessageParser
  Error = Class.new StandardError

  SHORT_MATCHER = { 'в' => 'viral_load', 'и' => 'immune_status' }.freeze
  FULL_MATCHER = {
    'viral_load' => %w[вн нагр вирус врус dy dbhec],
    'immune_status' => %w[ис иммун имун стат bc bvey]
  }.freeze

  def self.perform(message)
    new(message).perform
  end

  def initialize(message)
    @message = message.strip.downcase
  end

  def perform
    if one_result_message?
      [[parse_result_type, parse_value, parse_date]]
    else
      raise Error if message.split.size != 3

      [
        [:immune_status, immune_status_value, parse_date],
        [:viral_load, viral_load_value, parse_date]
      ]
    end
  end

  private

  attr_reader :message

  def one_result_message?
    message.match(/(\p{L})+/).present?
  end

  def parse_result_type
    identity = message.match(/([\p{L}\s])+/).to_a.first&.strip
    if identity&.size == 1
      SHORT_MATCHER[identity]
    elsif identity.present?
      FULL_MATCHER.find { |_, value| value.any? { |el| identity.include?(el) } }&.first
    end || (raise Error)
  end

  def parse_value
    message.gsub(/\p{L}/, '').strip.split.first.to_i
  end

  def parse_date
    return Date.today if message.split.size < 3

    date = message.split.last
    day, month, year = date.split(/[.\-:]/)
    year = "20#{year}" if year&.size == 2
    Date.parse("#{day}.#{month}.#{year}")
  rescue Date::Error
    Date.today
  end

  def immune_status_value
    message.split.first&.to_i
  end

  def viral_load_value
    message.split.second&.to_i
  end
end
