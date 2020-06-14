# frozen_string_literal: true

class AddEncryptionToTelegramId < ActiveRecord::Migration[6.0]
  def up
    rename_column :users, :telegram_chat_id, :telegram_chat_id_legacy
    add_column :users, :encrypted_telegram_chat_id, :string
    add_column :users, :encrypted_telegram_chat_id_iv, :string
    User.find_each { |u| u.update(telegram_chat_id: u.telegram_chat_id_legacy) }

    remove_column :users, :telegram_chat_id_legacy
    remove_column :users, :telegram_username
  end

  def down
    remove_column :users, :encrypted_telegram_chat_id
    remove_column :users, :encrypted_telegram_chat_id_iv
  end
end
