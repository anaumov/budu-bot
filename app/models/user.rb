# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :recoverable, :rememberable
  attr_encrypted :telegram_chat_id, key: Secrets.attr_encrypted_key

  before_create do
    self.telegram_chat_id_hash = Hasher.perform(telegram_chat_id)
  end

  has_many :test_results, dependent: :destroy
  has_many :user_actions, dependent: :destroy

  def notification_set?
    notification_time.present?
  end

  def pill_done!
    user_actions.create!(action_type: :pill_done)
    update!(last_notification_message_id: nil)
  end

  def pill_undone!
    user_actions.create!(action_type: :pill_undone)
    update!(last_notification_message_id: nil)
  end

  def turn_off_notifications!
    update!(notification_time: nil)
  end

  def update_notification_time!(hour)
    update!(notification_time: hour)
  end
end
