# frozen_string_literal: true

class CreateTestResults < ActiveRecord::Migration[6.0]
  def change
    create_table :test_results do |t|
      t.integer :user_id, null: false, index: true
      t.integer :value, null: false
      t.integer :result_type, null: false
      t.date :date, null: false
      t.json :message, default: {}
      t.timestamps null: false
    end
  end
end
