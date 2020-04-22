# frozen_string_literal: true

Rails.application.routes.draw do
  default_url_options host: 'bot.ikeepon.ru', protocol: 'https'
  devise_for :users
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  telegram_webhook TelegramWebhooksController
end
