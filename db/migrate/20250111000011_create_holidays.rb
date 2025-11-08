# frozen_string_literal: true

class CreateHolidays < ActiveRecord::Migration[8.1]
  def change
    create_table :holidays do |t|
      t.string :name, null: false
      t.date :date, null: false

      t.timestamps
    end

    add_index :holidays, :date, unique: true
  end
end
