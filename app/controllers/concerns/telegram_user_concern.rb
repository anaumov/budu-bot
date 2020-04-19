# frozen_string_literal: true

module TelegramUserConcern
  def current_user
    return unless from

    @current_user ||= create_user!
  end

  def create_user!
    User
      .create_with(user_params)
      .find_or_create_by!(telegram_id: from['id'])
  end

  def user_params
    from.slice('first_name', 'last_name').merge(telegram_username: from['username'])
  end
end
