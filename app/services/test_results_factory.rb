# frozen_string_literal: true

class TestResultsFactory
  def self.perform(user, message)
    new(user, message).perform
  end

  def initialize(user, message)
    @user = user
    @full_message = message
  end

  def perform
    full_message.split("\n").map { |message| { message: message, result: parse!(message) } }
  end

  private

  attr_reader :user, :full_message

  def parse!(message)
    ActiveRecord::Base.transaction do
      MessageParser.perform(message).map do |result_type, value, date|
        test_result = user.test_results.find_or_initialize_by(result_type: result_type, date: date)
        test_result.assign_attributes(value: value, message: { text: message })
        test_result.save!
        test_result
      end
    end
  rescue StandardError => e
    Bugsnag.notify(e) { |report| report.add_tab('Message', { message: message }) }
  end
end
