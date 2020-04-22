# frozen_string_literal: true

class UpdateUserIdentifier < ActiveRecord::Migration[6.0]
  def change
    rename_column :users, :telegram_id, :telegram_chat_id
  end
end
