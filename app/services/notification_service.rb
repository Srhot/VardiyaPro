# Service class for creating and sending notifications
# Handles both in-app notifications and email notifications
class NotificationService
  # Create notification when shift is assigned to employee
  def self.notify_shift_assigned(assignment)
    return unless assignment.employee.present?

    Notification.create_assignment_notification(
      assignment.employee,
      assignment,
      'shift_assigned',
      "You have been assigned to #{assignment.shift.shift_type} shift on #{assignment.shift.start_time.strftime('%B %d, %Y at %I:%M %p')}."
    )

    # Send email notification (if configured)
    # NotificationMailer.shift_assigned(assignment).deliver_later if assignment.employee.email.present?
  end

  # Create notification when assignment is confirmed
  def self.notify_assignment_confirmed(assignment)
    return unless assignment.employee.present?

    Notification.create_assignment_notification(
      assignment.employee,
      assignment,
      'assignment_confirmed',
      "Your #{assignment.shift.shift_type} shift assignment on #{assignment.shift.start_time.strftime('%B %d, %Y')} has been confirmed."
    )
  end

  # Create notification when assignment is cancelled
  def self.notify_assignment_cancelled(assignment)
    return unless assignment.employee.present?

    Notification.create_assignment_notification(
      assignment.employee,
      assignment,
      'assignment_cancelled',
      "Your #{assignment.shift.shift_type} shift assignment on #{assignment.shift.start_time.strftime('%B %d, %Y')} has been cancelled."
    )
  end

  # Create notification when shift is updated
  def self.notify_shift_updated(shift)
    # Notify all employees assigned to this shift
    shift.assignments.where(status: %w[pending confirmed]).each do |assignment|
      Notification.create_shift_notification(
        assignment.employee,
        shift,
        'shift_updated',
        "Your #{shift.shift_type} shift on #{shift.start_time.strftime('%B %d, %Y')} has been updated. Please check the details."
      )
    end
  end

  # Create notification when shift is deleted
  def self.notify_shift_deleted(shift)
    # Notify all employees assigned to this shift
    shift.assignments.each do |assignment|
      Notification.create_shift_notification(
        assignment.employee,
        shift,
        'shift_deleted',
        "The #{shift.shift_type} shift on #{shift.start_time.strftime('%B %d, %Y')} has been deleted."
      )
    end
  end

  # Create reminder notification for upcoming shift (can be called via background job)
  def self.send_shift_reminders
    # Find shifts starting in next 24 hours
    upcoming_shifts = Shift.where(
      'start_time BETWEEN ? AND ?',
      Time.current,
      24.hours.from_now
    ).where(active: true)

    upcoming_shifts.each do |shift|
      shift.assignments.confirmed.each do |assignment|
        # Check if reminder already sent
        existing_reminder = Notification.where(
          user_id: assignment.employee_id,
          notification_type: 'shift_reminder',
          related: shift
        ).where('created_at > ?', 24.hours.ago).exists?

        next if existing_reminder

        Notification.create_shift_notification(
          assignment.employee,
          shift,
          'shift_reminder',
          "Reminder: Your #{shift.shift_type} shift starts on #{shift.start_time.strftime('%B %d, %Y at %I:%M %p')}."
        )
      end
    end
  end

  # Bulk notification for department (admin/manager use)
  def self.notify_department(department, title, message)
    department.users.active.each do |user|
      Notification.create(
        user: user,
        title: title,
        message: message,
        notification_type: 'shift_updated' # generic type for bulk notifications
      )
    end
  end
end
