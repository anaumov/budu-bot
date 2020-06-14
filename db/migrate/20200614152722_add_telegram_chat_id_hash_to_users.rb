# frozen_string_literal: true

class AddTelegramChatIdHashToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :telegram_chat_id_hash, :string
    User.find_each { |u| u.update(telegram_chat_id_hash: Hasher.perform(u.telegram_chat_id)) }
  end
end
