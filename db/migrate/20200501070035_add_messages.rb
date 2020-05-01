# frozen_string_literal: true

class AddMessages < ActiveRecord::Migration[6.0]
  def change
    create_table :messages do |t|
      t.string :slug, null: false
      t.string :desc, null: false
      t.text :text, null: false
      t.timestamps null: false
    end
  end
end
