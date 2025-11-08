# frozen_string_literal: true

class CreateSolidCacheEntries < ActiveRecord::Migration[8.0]
  def change
    create_table :solid_cache_entries do |t|
      t.binary :key, null: false, limit: 1024
      t.binary :value, null: false, limit: 536_870_912
      t.datetime :created_at, null: false

      t.index :key, unique: true
      t.index :created_at
    end
  end
end
