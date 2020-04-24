# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable

  has_many :test_results
  has_many :user_actions

  def notification_set?
    notification_time.present?
  end

  def pill_done!
    user_actions.create!(action_type: :pill_done)
  end

  def pill_undone!
    user_actions.create!(action_type: :pill_undone)
  end
end
