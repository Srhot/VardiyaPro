class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :email, null: false
      t.string :name, null: false
      t.string :role, null: false, default: 'employee'
      t.string :password_digest, null: false
      t.string :phone
      t.boolean :active, default: true, null: false
      t.references :department, foreign_key: true

      t.timestamps
    end

    add_index :users, :email, unique: true
    add_index :users, :role
    add_index :users, :active
  end
end
