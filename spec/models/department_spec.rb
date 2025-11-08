# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Department, type: :model do
  describe 'associations' do
    it { should have_many(:users).dependent(:nullify) }
    it { should have_many(:shifts).dependent(:destroy) }
  end

  describe 'validations' do
    subject { build(:department) }

    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name).case_insensitive }
  end

  describe 'scopes' do
    let!(:active_dept) { create(:department, active: true) }
    let!(:inactive_dept) { create(:department, active: false) }

    describe '.active' do
      it 'returns only active departments' do
        expect(Department.active).to include(active_dept)
        expect(Department.active).not_to include(inactive_dept)
      end
    end

    describe '.search' do
      it 'searches by name' do
        dept = create(:department, name: 'Engineering')
        expect(Department.search('engineer')).to include(dept)
      end

      it 'searches by description' do
        dept = create(:department, description: 'Software development team')
        expect(Department.search('software')).to include(dept)
      end

      it 'is case insensitive' do
        dept = create(:department, name: 'Sales')
        expect(Department.search('SALES')).to include(dept)
      end
    end
  end

  describe 'callbacks' do
    it 'titleizes name before save' do
      dept = create(:department, name: 'engineering department')
      expect(dept.name).to eq('Engineering Department')
    end
  end
end
