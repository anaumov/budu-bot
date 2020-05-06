# frozen_string_literal: true

class AddLastNotificationMessageIdToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :last_notification_message_id, :integer
  end
end
