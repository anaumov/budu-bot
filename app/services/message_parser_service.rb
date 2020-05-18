# frozen_string_literal: true

class MessageParserService
  def self.perform(message, user)
    new(message, user).perform
  end

  def initialize(message, user)
    @message = message
    @user = user
  end

  def perform
    response_message = result_message
    response_message += Message.build(:message_parse_success) if success?
    { message: response_message, buttons: buttons }
  end

  private

  attr_reader :message, :user

  def results
    @results ||= TestResultsFactory.perform(user, message)
  end

  def result_message
    Message.test_result_message(results)
  end

  def buttons
    return [] unless success?

    ids = results.map { |el| el[:result]&.id }.compact
    [[{ text: Button.get(:cancel), callback_data: "remove_test_result:#{ids.first}-#{ids.last}}" }]]
  end

  def success?
    results.any? { |res| res[:result].present? }
  end
end
