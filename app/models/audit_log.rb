# frozen_string_literal: true

class AuditLog < ApplicationRecord
  # Associations
  belongs_to :user, optional: true # optional because system actions may not have a user
  belongs_to :auditable, polymorphic: true, optional: true # optional because record may be deleted

  # Constants
  ACTIONS = %w[create update delete].freeze

  # Validations
  validates :action, presence: true, inclusion: { in: ACTIONS }
  validates :auditable_type, presence: true

  # Scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :by_user, ->(user_id) { where(user_id: user_id) }
  scope :by_action, ->(action) { where(action: action) }
  scope :by_auditable_type, ->(type) { where(auditable_type: type) }
  scope :for_record, ->(type, id) { where(auditable_type: type, auditable_id: id) }

  # Class method to create audit log
  def self.log_action(user:, auditable:, action:, changes: {}, request: nil)
    create(
      user: user,
      auditable: auditable,
      auditable_type: auditable.class.name,
      auditable_id: auditable.id,
      action: action,
      audit_changes: changes,  # Renamed from 'changes' to 'audit_changes' to avoid ActiveRecord conflict
      ip_address: request&.remote_ip,
      user_agent: request&.user_agent
    )
  end

  # Instance methods
  def auditable_name
    return 'Deleted Record' unless auditable.present?

    case auditable_type
    when 'User'
      auditable.name
    when 'Shift'
      "#{auditable.shift_type} shift on #{auditable.start_time.strftime('%Y-%m-%d')}"
    when 'Assignment'
      "Assignment ##{auditable.id}"
    when 'Department'
      auditable.name
    else
      "#{auditable_type} ##{auditable_id}"
    end
  end

  def user_name
    user&.name || 'System'
  end

  def summary
    "#{user_name} #{action}d #{auditable_type} ##{auditable_id}"
  end
end
