# frozen_string_literal: true

module TelegramUserConcern
  def current_user
    return unless from

    @current_user ||= create_user!
  end

  def create_user!
    User.find_by(telegram_chat_id_hash: Hasher.perform(chat['id'])) ||
      User.create!(telegram_chat_id: chat['id'])
  end

  def user_params
    from.slice('first_name', 'last_name').merge(telegram_username: from['username'])
  end
end
