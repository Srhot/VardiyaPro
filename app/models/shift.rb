# frozen_string_literal: true

class Shift < ApplicationRecord
  include Auditable

  # Associations
  belongs_to :department
  has_many :assignments, dependent: :destroy
  has_many :users, through: :assignments

  # Constants
  SHIFT_TYPES = %w[morning afternoon evening night flexible on_call].freeze
  MIN_DURATION = 4.hours
  MAX_DURATION = 12.hours

  # Validations
  validates :shift_type, presence: true, inclusion: { in: SHIFT_TYPES }
  validates :start_time, presence: true
  validates :end_time, presence: true
  validates :required_staff, presence: true, numericality: { greater_than: 0 }
  validate :end_time_after_start_time
  validate :duration_within_limits

  # Scopes
  scope :active, -> { where(active: true) }
  scope :by_department, ->(department_id) { where(department_id: department_id) }
  scope :by_type, ->(type) { where(shift_type: type) }
  scope :upcoming, -> { where('start_time >= ?', Time.current).order(:start_time) }
  scope :in_range, ->(start_date, end_date) { where('start_time >= ? AND end_time <= ?', start_date, end_date) }
  scope :on_date, ->(date) { where('DATE(start_time) = ?', date) }
  scope :with_available_slots, lambda {
    joins('LEFT JOIN assignments ON assignments.shift_id = shifts.id AND assignments.status = \'confirmed\'')
      .group('shifts.id')
      .having('COUNT(assignments.id) < shifts.required_staff')
  }
  scope :search, lambda { |query|
    return all if query.blank?

    joins(:department).where('LOWER(departments.name) LIKE ? OR LOWER(shifts.description) LIKE ?',
                             "%#{query.downcase}%", "%#{query.downcase}%")
  }

  # Callbacks
  after_update :notify_shift_updated, if: :saved_changes?
  before_destroy :notify_shift_deleted

  # Instance methods
  def duration_hours
    return 0 unless start_time && end_time

    ((end_time - start_time) / 1.hour).round(2)
  end

  def filled?
    assignments.confirmed.count >= required_staff
  end

  def available_slots
    required_staff - assignments.confirmed.count
  end

  private

  # Notification callbacks
  def notify_shift_updated
    NotificationService.notify_shift_updated(self)
    Rails.logger.info "📧 Shift #{id} updated, notifying assigned employees"
  end

  def notify_shift_deleted
    NotificationService.notify_shift_deleted(self)
    Rails.logger.info "📧 Shift #{id} being deleted, notifying assigned employees"
  end

  # Validation methods
  def end_time_after_start_time
    return if end_time.blank? || start_time.blank?

    return unless end_time <= start_time

    errors.add(:end_time, 'must be after start time')
  end

  def duration_within_limits
    return if end_time.blank? || start_time.blank?

    duration = end_time - start_time
    if duration < MIN_DURATION
      errors.add(:base, "Shift duration must be at least #{MIN_DURATION / 3600} hours")
    elsif duration > MAX_DURATION
      errors.add(:base, "Shift duration cannot exceed #{MAX_DURATION / 3600} hours")
    end
  end
end
