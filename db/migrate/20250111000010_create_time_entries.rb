# frozen_string_literal: true

class CreateTimeEntries < ActiveRecord::Migration[8.1]
  def change
    create_table :time_entries do |t|
      t.references :assignment, null: false, foreign_key: true, index: { unique: true }
      t.datetime :clock_in_time, null: false
      t.datetime :clock_out_time
      t.text :notes

      t.timestamps
    end

    add_index :time_entries, :clock_in_time
    add_index :time_entries, :clock_out_time
  end
end
