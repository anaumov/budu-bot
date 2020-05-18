# frozen_string_literal: true

class Message < ApplicationRecord
  scope :ordered, -> { order(id: :desc) }

  def self.build(slug, **args)
    message = find_by!(slug: slug)
    I18n.interpolate(message.text, **args)
  end

  def self.test_result_message(results)
    report = results.map do |result|
      if result[:result].present?
        "✅ «#{result[:message]}» – #{TestResult.to_message(result[:result])}"
      else
        "❌ «#{result[:message]}» – не удалось распознать"
      end
    end
    build(:result_saved, report: report.join("\n"))
  end
end
