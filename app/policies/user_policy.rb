# frozen_string_literal: true

# User authorization policy
# Defines who can perform what actions on User records
class UserPolicy < ApplicationPolicy
  # Admins and HR can view all users
  # Managers can view users in their department
  # Employees can only view their own profile
  def index?
    user.present?
  end

  # Admins and HR can view any user
  # Managers can view users in their department
  # Employees can view their own profile
  def show?
    return true if user&.admin? || user&.hr?
    return true if user&.manager? && same_department?

    own_profile?
  end

  # Only admins and HR can create new users
  def create?
    user&.admin? || user&.hr?
  end

  # Admins and HR can update any user
  # Managers can update users in their department (except role changes)
  # Users can update their own profile (limited fields)
  def update?
    return true if user&.admin? || user&.hr?
    return true if user&.manager? && same_department?

    own_profile?
  end

  # Only admins can delete users (soft delete by deactivating)
  def destroy?
    user&.admin?
  end

  # Users can update their own password
  def update_password?
    own_profile?
  end

  # Only admins and HR can activate/deactivate users
  def activate?
    user&.admin? || user&.hr?
  end

  def deactivate?
    user&.admin? || user&.hr?
  end

  # Permitted attributes based on user role
  def permitted_attributes
    if user&.admin? || user&.hr?
      # Admins and HR can modify all fields
      %i[email name role phone active department_id password password_confirmation]
    elsif user&.manager?
      # Managers can modify limited fields (no role changes)
      %i[email name phone department_id]
    else
      # Employees can only modify their own profile fields
      %i[name phone email]
    end
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user&.admin? || user&.hr?
        # Admins and HR see all users
        scope.all
      elsif user&.manager?
        # Managers see users in their department
        scope.where(department_id: user.department_id)
      else
        # Employees see only themselves
        scope.where(id: user.id)
      end
    end
  end

  private

  def own_profile?
    user && record.id == user.id
  end

  def same_department?
    user&.department_id && user.department_id == record.department_id
  end
end
