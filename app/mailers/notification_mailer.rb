class NotificationMailer < ApplicationMailer
  default from: 'notifications@vardiyapro.com'

  # Email notification when shift is assigned
  def shift_assigned(assignment)
    @assignment = assignment
    @employee = assignment.employee
    @shift = assignment.shift

    mail(
      to: @employee.email,
      subject: 'New Shift Assignment - VardiyaPro'
    )
  end

  # Email notification when assignment is confirmed
  def assignment_confirmed(assignment)
    @assignment = assignment
    @employee = assignment.employee
    @shift = assignment.shift

    mail(
      to: @employee.email,
      subject: 'Shift Assignment Confirmed - VardiyaPro'
    )
  end

  # Email notification when assignment is cancelled
  def assignment_cancelled(assignment)
    @assignment = assignment
    @employee = assignment.employee
    @shift = assignment.shift

    mail(
      to: @employee.email,
      subject: 'Shift Assignment Cancelled - VardiyaPro'
    )
  end

  # Email reminder for upcoming shift
  def shift_reminder(assignment)
    @assignment = assignment
    @employee = assignment.employee
    @shift = assignment.shift

    mail(
      to: @employee.email,
      subject: 'Shift Reminder - VardiyaPro'
    )
  end
end
