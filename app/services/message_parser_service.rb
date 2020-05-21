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
    results
    response_message = Message.build("parse_#{status}")
    response_message += Message.test_result_message(results)
    response_message += Message.build(status == :fail ? :how_to_register_dupe : :remove_data_note)
    { message: response_message, buttons: buttons, status: status }
  end

  private

  attr_reader :message, :user

  def results
    @results ||= TestResultsFactory.perform(user, message)
  end

  def buttons
    return [] if status == :fail

    ids = results.map { |el| el[:result]&.map(&:id) }.compact.sort
    [[{ text: Button.get(:remove), callback_data: "remove_test_result:#{ids.first}-#{ids.last}}" }]]
  end

  def status
    return @status if @status

    @status = if results.none? { |res| res[:result].present? }
                :fail
              elsif results.all? { |res| res[:result].present? }
                :success
              else
                :has_errors
              end
  end
end
