class CreateShifts < ActiveRecord::Migration[8.0]
  def change
    create_table :shifts do |t|
      t.references :department, null: false, foreign_key: true
      t.string :shift_type, null: false  # morning, afternoon, evening, night, flexible, on_call
      t.datetime :start_time, null: false
      t.datetime :end_time, null: false
      t.integer :required_staff, null: false, default: 1
      t.text :description
      t.boolean :active, default: true, null: false

      t.timestamps
    end

    add_index :shifts, :shift_type
    add_index :shifts, :start_time
    add_index :shifts, :end_time
    add_index :shifts, [:department_id, :start_time]
    add_index :shifts, :active
  end
end
