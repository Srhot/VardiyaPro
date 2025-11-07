class CreateAssignments < ActiveRecord::Migration[8.0]
  def change
    create_table :assignments do |t|
      t.references :shift, null: false, foreign_key: true
      t.references :employee, null: false, foreign_key: { to_table: :users }
      t.string :status, default: 'pending', null: false  # pending, confirmed, completed, cancelled
      t.text :notes

      t.timestamps
    end

    add_index :assignments, [:shift_id, :employee_id], unique: true
    add_index :assignments, :status
    add_index :assignments, :employee_id
  end
end
