# frozen_string_literal: true

# Holiday model for system-defined holidays
class Holiday < ApplicationRecord
  # Validations
  validates :name, presence: true
  validates :date, presence: true, uniqueness: true

  # Scopes
  scope :upcoming, -> { where('date >= ?', Date.current).order(:date) }
  scope :past, -> { where('date < ?', Date.current).order(date: :desc) }
  scope :for_year, ->(year) { where('EXTRACT(YEAR FROM date) = ?', year) }
  scope :for_month, ->(year, month) { where('EXTRACT(YEAR FROM date) = ? AND EXTRACT(MONTH FROM date) = ?', year, month) }

  # Class methods
  def self.is_holiday?(date)
    exists?(date: date)
  end

  def self.holidays_between(start_date, end_date)
    where(date: start_date..end_date).order(:date)
  end

  # Instance methods
  def past?
    date < Date.current
  end

  def upcoming?
    date >= Date.current
  end

  def today?
    date == Date.current
  end
end
