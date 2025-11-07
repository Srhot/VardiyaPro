class Department < ApplicationRecord
  # Associations
  has_many :users, dependent: :nullify
  has_many :shifts, dependent: :destroy

  # Validations
  validates :name, presence: true, uniqueness: { case_sensitive: false }

  # Scopes
  scope :active, -> { where(active: true) }
  scope :search, ->(query) {
    return all if query.blank?
    where('LOWER(name) LIKE ? OR LOWER(description) LIKE ?', "%#{query.downcase}%", "%#{query.downcase}%")
  }

  # Callbacks
  before_save :titleize_name

  private

  def titleize_name
    self.name = name.titleize if name.present?
  end
end
