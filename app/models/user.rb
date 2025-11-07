class User < ApplicationRecord
  include Auditable

  # Associations
  belongs_to :department, optional: true
  has_many :assignments, foreign_key: 'employee_id', dependent: :destroy
  has_many :shifts, through: :assignments
  has_many :created_shifts, class_name: 'Shift', foreign_key: 'creator_id', dependent: :nullify
  has_many :notifications, dependent: :destroy

  # Authentication
  has_secure_password validations: false

  # Validations
  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :name, presence: true
  validates :role, presence: true, inclusion: { in: %w[admin manager employee hr] }
  validates :password, length: { minimum: 6 }, if: :password_digest_changed?

  # Scopes
  scope :active, -> { where(active: true) }
  scope :by_role, ->(role) { where(role: role) }
  scope :in_department, ->(department_id) { where(department_id: department_id) }
  scope :search, ->(query) {
    return all if query.blank?
    where('LOWER(name) LIKE ? OR LOWER(email) LIKE ?', "%#{query.downcase}%", "%#{query.downcase}%")
  }

  # Callbacks
  before_save :downcase_email

  # Instance methods
  def admin?
    role == 'admin'
  end

  def manager?
    role == 'manager'
  end

  def employee?
    role == 'employee'
  end

  def hr?
    role == 'hr'
  end

  private

  def downcase_email
    self.email = email.downcase if email.present?
  end
end
