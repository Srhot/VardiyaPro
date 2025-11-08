# frozen_string_literal: true

class Notification < ApplicationRecord
  # Associations
  belongs_to :user
  belongs_to :related, polymorphic: true, optional: true

  # Notification types
  NOTIFICATION_TYPES = %w[
    shift_assigned
    shift_confirmed
    shift_cancelled
    shift_reminder
    shift_updated
    shift_deleted
    assignment_confirmed
    assignment_cancelled
  ].freeze

  # Validations
  validates :title, presence: true
  validates :message, presence: true
  validates :notification_type, presence: true, inclusion: { in: NOTIFICATION_TYPES }

  # Scopes
  scope :unread, -> { where(read: false) }
  scope :read, -> { where(read: true) }
  scope :recent, -> { order(created_at: :desc) }
  scope :by_type, ->(type) { where(notification_type: type) }
  scope :for_user, ->(user_id) { where(user_id: user_id) }

  # Instance methods
  def mark_as_read!
    update(read: true)
  end

  def mark_as_unread!
    update(read: false)
  end

  # Class methods
  def self.mark_all_as_read(user_id)
    where(user_id: user_id, read: false).update_all(read: true)
  end

  def self.create_shift_notification(user, shift, type, message = nil)
    title = generate_title(type, shift)
    message ||= generate_message(type, shift)

    create(
      user: user,
      title: title,
      message: message,
      notification_type: type,
      related: shift
    )
  end

  def self.create_assignment_notification(user, assignment, type, message = nil)
    title = generate_title(type, assignment)
    message ||= generate_message(type, assignment)

    create(
      user: user,
      title: title,
      message: message,
      notification_type: type,
      related: assignment
    )
  end

  def self.generate_title(type, _object)
    case type
    when 'shift_assigned'
      'New Shift Assignment'
    when 'shift_confirmed'
      'Shift Confirmed'
    when 'shift_cancelled'
      'Shift Cancelled'
    when 'shift_reminder'
      'Shift Reminder'
    when 'shift_updated'
      'Shift Updated'
    when 'shift_deleted'
      'Shift Deleted'
    when 'assignment_confirmed'
      'Assignment Confirmed'
    when 'assignment_cancelled'
      'Assignment Cancelled'
    else
      'Notification'
    end
  end

  def self.generate_message(type, _object)
    case type
    when 'shift_assigned'
      'You have been assigned to a new shift.'
    when 'shift_confirmed'
      'Your shift assignment has been confirmed.'
    when 'shift_cancelled'
      'Your shift has been cancelled.'
    when 'shift_reminder'
      'Reminder: Your shift is coming up soon.'
    when 'shift_updated'
      'Your shift details have been updated.'
    when 'shift_deleted'
      'A shift you were assigned to has been deleted.'
    when 'assignment_confirmed'
      'Your shift assignment has been confirmed.'
    when 'assignment_cancelled'
      'Your shift assignment has been cancelled.'
    else
      'You have a new notification.'
    end
  end
end
