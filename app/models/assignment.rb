class Assignment < ApplicationRecord
  # Associations
  belongs_to :shift
  belongs_to :employee, class_name: 'User', foreign_key: 'employee_id'

  # Constants
  STATUSES = %w[pending confirmed completed cancelled].freeze

  # Validations
  validates :status, presence: true, inclusion: { in: STATUSES }
  validates :employee_id, uniqueness: { scope: :shift_id, message: 'already assigned to this shift' }
  validate :no_overlapping_assignments, on: :create
  validate :shift_not_overfilled

  # Scopes
  scope :pending, -> { where(status: 'pending') }
  scope :confirmed, -> { where(status: 'confirmed') }
  scope :completed, -> { where(status: 'completed') }
  scope :cancelled, -> { where(status: 'cancelled') }
  scope :active, -> { where(status: %w[pending confirmed]) }
  scope :for_employee, ->(employee_id) { where(employee_id: employee_id) }
  scope :for_shift, ->(shift_id) { where(shift_id: shift_id) }

  # Callbacks
  after_create :notify_employee
  after_update :notify_status_change, if: :saved_change_to_status?

  private

  # CRITICAL VALIDATION: Prevents double-booking employees
  # Checks if employee has any overlapping confirmed/pending assignments
  def no_overlapping_assignments
    return unless shift.present? && employee.present?

    # Get this shift's time range
    shift_start = shift.start_time
    shift_end = shift.end_time

    # Find any overlapping assignments for this employee
    overlapping = Assignment
      .joins(:shift)
      .where(employee_id: employee_id)
      .where(status: %w[pending confirmed])
      .where.not(id: id) # Exclude current record if updating
      .where('shifts.start_time < ? AND shifts.end_time > ?', shift_end, shift_start)

    if overlapping.exists?
      overlapping_shift = overlapping.first.shift
      errors.add(:base, "Employee is already assigned to an overlapping shift (#{overlapping_shift.shift_type} from #{overlapping_shift.start_time.strftime('%Y-%m-%d %H:%M')} to #{overlapping_shift.end_time.strftime('%Y-%m-%d %H:%M')})")
    end
  end

  # Validates that shift has available slots
  def shift_not_overfilled
    return unless shift.present?

    # Count confirmed assignments for this shift (excluding current if updating)
    confirmed_count = Assignment
      .where(shift_id: shift_id)
      .where(status: %w[confirmed])
      .where.not(id: id)
      .count

    if confirmed_count >= shift.required_staff
      errors.add(:base, "Shift is already full (#{shift.required_staff} required, #{confirmed_count} confirmed)")
    end
  end

  # Notification placeholders (will be implemented with ActionMailer/Cable)
  def notify_employee
    # TODO: Send notification to employee about new assignment
    Rails.logger.info "📧 Assignment #{id} created for employee #{employee.email}"
  end

  def notify_status_change
    # TODO: Send notification to employee about status change
    Rails.logger.info "📧 Assignment #{id} status changed to #{status} for employee #{employee.email}"
  end
end
