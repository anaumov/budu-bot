# frozen_string_literal: true

class UserAction < ApplicationRecord
  enum action_type: %i[pill_done pill_undone]
  belongs_to :user
  validate :one_action_per_day

  scope :in_day, ->(time) { where(created_at: (time.beginning_of_day..time.end_of_day)) }
  scope :today, -> { in_day(Time.zone.now) }

  private

  def one_action_per_day
    scope = UserAction.where(action_type: action_type, user_id: user_id)
    scope = (persisted? ? scope.in_day(created_at) : scope.today)
    errors.add(:base, :too_many_pills, message: 'One pill action per day') if scope.any?
  end
end
