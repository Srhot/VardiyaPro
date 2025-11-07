# Auditable concern for models that need audit logging
# Include this module in models that should be audited
module Auditable
  extend ActiveSupport::Concern

  included do
    has_many :audit_logs, as: :auditable, dependent: :destroy

    after_create :log_create
    after_update :log_update
    before_destroy :log_destroy

    # Store current user for audit logging
    attr_accessor :current_user_for_audit, :current_request_for_audit
  end

  private

  def log_create
    return unless should_audit?

    AuditLog.log_action(
      user: current_user_for_audit,
      auditable: self,
      action: 'create',
      changes: auditable_changes,
      request: current_request_for_audit
    )
  end

  def log_update
    return unless should_audit?
    return unless saved_changes.any?

    AuditLog.log_action(
      user: current_user_for_audit,
      auditable: self,
      action: 'update',
      changes: auditable_changes,
      request: current_request_for_audit
    )
  end

  def log_destroy
    return unless should_audit?

    # Use attributes instead of self because record will be destroyed
    AuditLog.create(
      user: current_user_for_audit,
      auditable_type: self.class.name,
      auditable_id: id,
      action: 'delete',
      changes: { deleted_attributes: auditable_attributes },
      ip_address: current_request_for_audit&.remote_ip,
      user_agent: current_request_for_audit&.user_agent
    )
  end

  def should_audit?
    # Can be overridden in models to control when to audit
    true
  end

  def auditable_changes
    # Can be overridden in models to customize what changes to log
    if persisted? && saved_changes.present?
      saved_changes.except('updated_at')
    else
      attributes.except('created_at', 'updated_at')
    end
  end

  def auditable_attributes
    # Can be overridden in models to customize what attributes to log on delete
    attributes.except('created_at', 'updated_at')
  end
end
