# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:telegram_chat_id)
  end
end
