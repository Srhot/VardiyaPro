# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Shift, type: :model do
  describe 'associations' do
    it { should belong_to(:department) }
    it { should have_many(:assignments).dependent(:destroy) }
    it { should have_many(:users).through(:assignments) }
  end

  describe 'validations' do
    subject { build(:shift) }

    it { should validate_presence_of(:shift_type) }
    it { should validate_presence_of(:start_time) }
    it { should validate_presence_of(:end_time) }
    it { should validate_presence_of(:required_staff) }
    it { should validate_inclusion_of(:shift_type).in_array(Shift::SHIFT_TYPES) }

    describe 'end_time_after_start_time' do
      it 'is invalid when end_time is before start_time' do
        shift = build(:shift, start_time: Time.current, end_time: Time.current - 1.hour)
        expect(shift).not_to be_valid
        expect(shift.errors[:end_time]).to include('must be after start time')
      end

      it 'is valid when end_time is after start_time' do
        shift = build(:shift, start_time: Time.current, end_time: Time.current + 8.hours)
        expect(shift).to be_valid
      end
    end

    describe 'duration_within_limits' do
      it 'is invalid when duration is less than 4 hours' do
        shift = build(:shift,
                     start_time: Time.current,
                     end_time: Time.current + 3.hours)
        expect(shift).not_to be_valid
        expect(shift.errors[:base]).to include('Shift duration must be at least 4 hours')
      end

      it 'is invalid when duration exceeds 12 hours' do
        shift = build(:shift,
                     start_time: Time.current,
                     end_time: Time.current + 13.hours)
        expect(shift).not_to be_valid
        expect(shift.errors[:base]).to include('Shift duration cannot exceed 12 hours')
      end

      it 'is valid when duration is between 4 and 12 hours' do
        shift = build(:shift,
                     start_time: Time.current,
                     end_time: Time.current + 8.hours)
        expect(shift).to be_valid
      end
    end
  end

  describe 'scopes' do
    let!(:active_shift) { create(:shift, active: true) }
    let!(:inactive_shift) { create(:shift, active: false) }
    let!(:morning_shift) { create(:shift, :morning) }
    let!(:night_shift) { create(:shift, :night) }
    let!(:department) { create(:department) }
    let!(:dept_shift) { create(:shift, department: department) }

    describe '.active' do
      it 'returns only active shifts' do
        expect(Shift.active).to include(active_shift)
        expect(Shift.active).not_to include(inactive_shift)
      end
    end

    describe '.by_department' do
      it 'filters shifts by department' do
        expect(Shift.by_department(department.id)).to include(dept_shift)
        expect(Shift.by_department(department.id)).not_to include(morning_shift)
      end
    end

    describe '.by_type' do
      it 'filters shifts by type' do
        expect(Shift.by_type('morning')).to include(morning_shift)
        expect(Shift.by_type('morning')).not_to include(night_shift)
      end
    end

    describe '.upcoming' do
      let!(:past_shift) { create(:shift, start_time: 1.day.ago) }
      let!(:future_shift) { create(:shift, start_time: 1.day.from_now) }

      it 'returns only future shifts' do
        expect(Shift.upcoming).to include(future_shift)
        expect(Shift.upcoming).not_to include(past_shift)
      end
    end

    describe '.in_range' do
      let!(:shift_in_range) { create(:shift, start_time: 2.days.from_now, end_time: 2.days.from_now + 8.hours) }
      let!(:shift_out_range) { create(:shift, start_time: 10.days.from_now, end_time: 10.days.from_now + 8.hours) }

      it 'returns shifts within date range' do
        start_date = 1.day.from_now
        end_date = 5.days.from_now
        expect(Shift.in_range(start_date, end_date)).to include(shift_in_range)
        expect(Shift.in_range(start_date, end_date)).not_to include(shift_out_range)
      end
    end
  end

  describe 'instance methods' do
    describe '#duration_hours' do
      it 'calculates duration in hours' do
        shift = create(:shift,
                      start_time: Time.current,
                      end_time: Time.current + 8.hours)
        expect(shift.duration_hours).to eq(8.0)
      end

      it 'returns 0 when times are nil' do
        shift = Shift.new
        expect(shift.duration_hours).to eq(0)
      end
    end

    describe '#filled?' do
      let(:shift) { create(:shift, required_staff: 2) }

      it 'returns false when shift has fewer confirmed assignments than required' do
        create(:assignment, :confirmed, shift: shift)
        expect(shift.filled?).to be false
      end

      it 'returns true when shift has enough confirmed assignments' do
        create(:assignment, :confirmed, shift: shift)
        create(:assignment, :confirmed, shift: shift)
        expect(shift.reload.filled?).to be true
      end
    end

    describe '#available_slots' do
      let(:shift) { create(:shift, required_staff: 3) }

      it 'returns remaining slots' do
        create(:assignment, :confirmed, shift: shift)
        expect(shift.reload.available_slots).to eq(2)
      end
    end
  end

  describe 'Auditable concern' do
    it 'includes Auditable module' do
      expect(Shift.included_modules).to include(Auditable)
    end
  end
end
