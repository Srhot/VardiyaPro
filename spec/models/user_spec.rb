# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it { should belong_to(:department).optional }
    it { should have_many(:assignments).dependent(:destroy) }
    it { should have_many(:shifts).through(:assignments) }
    it { should have_many(:notifications).dependent(:destroy) }
  end

  describe 'validations' do
    subject { build(:user) }

    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:role) }
    it { should validate_inclusion_of(:role).in_array(%w[admin manager employee hr]) }
    it { should validate_uniqueness_of(:email).case_insensitive }

    it 'validates email format' do
      user = build(:user, email: 'invalid_email')
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include('is invalid')
    end

    it 'validates password length on create' do
      user = build(:user, password: '12345', password_confirmation: '12345')
      expect(user).not_to be_valid
      expect(user.errors[:password]).to include('is too short (minimum is 6 characters)')
    end
  end

  describe 'scopes' do
    let!(:active_user) { create(:user, active: true) }
    let!(:inactive_user) { create(:user, active: false) }
    let!(:admin_user) { create(:user, :admin) }
    let!(:department) { create(:department) }
    let!(:user_in_dept) { create(:user, department: department) }

    describe '.active' do
      it 'returns only active users' do
        expect(User.active).to include(active_user)
        expect(User.active).not_to include(inactive_user)
      end
    end

    describe '.by_role' do
      it 'filters users by role' do
        expect(User.by_role('admin')).to include(admin_user)
        expect(User.by_role('employee')).not_to include(admin_user)
      end
    end

    describe '.in_department' do
      it 'filters users by department' do
        expect(User.in_department(department.id)).to include(user_in_dept)
        expect(User.in_department(department.id)).not_to include(active_user)
      end
    end

    describe '.search' do
      it 'searches by name' do
        user = create(:user, name: 'John Doe')
        expect(User.search('john')).to include(user)
      end

      it 'searches by email' do
        user = create(:user, email: 'test@example.com')
        expect(User.search('test@')).to include(user)
      end

      it 'is case insensitive' do
        user = create(:user, name: 'Jane Smith')
        expect(User.search('JANE')).to include(user)
      end
    end
  end

  describe 'callbacks' do
    it 'downcases email before save' do
      user = create(:user, email: 'TEST@EXAMPLE.COM')
      expect(user.email).to eq('test@example.com')
    end
  end

  describe 'instance methods' do
    describe 'role checking methods' do
      it 'returns true for admin?' do
        user = create(:user, :admin)
        expect(user.admin?).to be true
        expect(user.manager?).to be false
      end

      it 'returns true for manager?' do
        user = create(:user, :manager)
        expect(user.manager?).to be true
        expect(user.admin?).to be false
      end

      it 'returns true for employee?' do
        user = create(:user, :employee)
        expect(user.employee?).to be true
        expect(user.admin?).to be false
      end

      it 'returns true for hr?' do
        user = create(:user, :hr)
        expect(user.hr?).to be true
        expect(user.admin?).to be false
      end
    end
  end

  describe 'password encryption' do
    it 'encrypts password using bcrypt' do
      user = create(:user, password: 'password123')
      expect(user.password_digest).not_to eq('password123')
      expect(user.authenticate('password123')).to eq(user)
    end

    it 'returns false for incorrect password' do
      user = create(:user, password: 'password123')
      expect(user.authenticate('wrong_password')).to be false
    end
  end

  describe 'Auditable concern' do
    it 'includes Auditable module' do
      expect(User.included_modules).to include(Auditable)
    end
  end
end
