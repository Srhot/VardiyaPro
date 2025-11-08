# frozen_string_literal: true

class CreateAuditLogs < ActiveRecord::Migration[8.0]
  def change
    create_table :audit_logs do |t|
      # User who performed the action
      t.references :user, foreign_key: true

      # What was changed (polymorphic)
      t.string :auditable_type, null: false
      t.bigint :auditable_id, null: false

      # Action type: create, update, delete
      t.string :action, null: false

      # Changes made (JSON)
      t.jsonb :changes, default: {}

      # Additional context
      t.string :ip_address
      t.string :user_agent

      t.timestamps
    end

    add_index :audit_logs, %i[auditable_type auditable_id]
    add_index :audit_logs, :user_id
    add_index :audit_logs, :action
    add_index :audit_logs, :created_at
  end
end
