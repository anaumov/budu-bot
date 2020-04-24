# frozen_string_literal: true
class CreateTrackPills < ActiveRecord::Migration[6.0]
  def change
    create_table :user_actions do |t|
      t.integer :action_type, null: false
      t.integer :user_id, null: false, index: true
      t.timestamps null: false
    end
  end
end
