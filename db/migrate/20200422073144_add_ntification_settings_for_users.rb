# frozen_string_literal: true

class AddNtificationSettingsForUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :notification_time, :integer
  end
end
