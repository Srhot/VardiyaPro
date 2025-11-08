# frozen_string_literal: true

# TimeEntry model for tracking actual clock in/out times
class TimeEntry < ApplicationRecord
  # Associations
  belongs_to :assignment

  # Validations
  validates :assignment, presence: true, uniqueness: true
  validates :clock_in_time, presence: true
  validate :clock_out_after_clock_in

  # Scopes
  scope :clocked_in, -> { where.not(clock_in_time: nil).where(clock_out_time: nil) }
  scope :clocked_out, -> { where.not(clock_out_time: nil) }
  scope :for_date_range, lambda { |start_date, end_date|
    where('clock_in_time >= ? AND clock_in_time <= ?', start_date, end_date)
  }

  # Instance methods
  def worked_hours
    return 0 unless clock_in_time && clock_out_time

    ((clock_out_time - clock_in_time) / 3600.0).round(2)
  end

  def clocked_in?
    clock_in_time.present? && clock_out_time.nil?
  end

  def clocked_out?
    clock_out_time.present?
  end

  private

  def clock_out_after_clock_in
    return unless clock_in_time && clock_out_time

    if clock_out_time <= clock_in_time
      errors.add(:clock_out_time, 'must be after clock in time')
    end
  end
end
