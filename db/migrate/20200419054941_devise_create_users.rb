# frozen_string_literal: true

class DeviseCreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      ## Database authenticatable
      t.string :email,              default: "", index: true
      t.string :encrypted_password, default: ""
      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at
      ## Rememberable
      t.datetime :remember_created_at

      t.integer :telegram_id
      t.string :first_name
      t.string :last_name
      t.string :telegram_username

      t.timestamps null: false
    end

    add_index :users, :reset_password_token, unique: true
  end
end
