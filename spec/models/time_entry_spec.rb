# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TimeEntry, type: :model do
  describe 'associations' do
    it { should belong_to(:assignment) }
  end

  describe 'validations' do
    it { should validate_presence_of(:assignment) }
    it { should validate_presence_of(:clock_in_time) }

    describe 'clock_out_after_clock_in' do
      it 'is valid when clock_out_time is after clock_in_time' do
        time_entry = build(:time_entry, clock_in_time: 2.hours.ago, clock_out_time: 1.hour.ago)
        expect(time_entry).to be_valid
      end

      it 'is invalid when clock_out_time is before clock_in_time' do
        time_entry = build(:time_entry, clock_in_time: 1.hour.ago, clock_out_time: 2.hours.ago)
        expect(time_entry).not_to be_valid
        expect(time_entry.errors[:clock_out_time]).to include('must be after clock in time')
      end

      it 'is invalid when clock_out_time equals clock_in_time' do
        time = Time.current
        time_entry = build(:time_entry, clock_in_time: time, clock_out_time: time)
        expect(time_entry).not_to be_valid
      end
    end

    describe 'uniqueness' do
      let(:assignment) { create(:assignment, status: 'confirmed') }

      it 'validates uniqueness of assignment' do
        create(:time_entry, assignment: assignment)
        duplicate = build(:time_entry, assignment: assignment)
        expect(duplicate).not_to be_valid
        expect(duplicate.errors[:assignment]).to include('has already been taken')
      end
    end
  end

  describe 'scopes' do
    let!(:clocked_in_entry) { create(:time_entry, clock_in_time: 1.hour.ago, clock_out_time: nil) }
    let!(:clocked_out_entry) { create(:time_entry, :clocked_out, clock_in_time: 2.hours.ago, clock_out_time: 1.hour.ago) }

    describe '.clocked_in' do
      it 'returns only entries with no clock_out_time' do
        expect(TimeEntry.clocked_in).to include(clocked_in_entry)
        expect(TimeEntry.clocked_in).not_to include(clocked_out_entry)
      end
    end

    describe '.clocked_out' do
      it 'returns only entries with clock_out_time' do
        expect(TimeEntry.clocked_out).to include(clocked_out_entry)
        expect(TimeEntry.clocked_out).not_to include(clocked_in_entry)
      end
    end

    describe '.for_date_range' do
      let!(:january_entry) { create(:time_entry, clock_in_time: Date.new(2025, 1, 15).to_time) }
      let!(:february_entry) { create(:time_entry, clock_in_time: Date.new(2025, 2, 15).to_time) }

      it 'returns entries within date range' do
        start_date = Date.new(2025, 1, 1)
        end_date = Date.new(2025, 1, 31)
        expect(TimeEntry.for_date_range(start_date, end_date)).to include(january_entry)
        expect(TimeEntry.for_date_range(start_date, end_date)).not_to include(february_entry)
      end
    end
  end

  describe '#worked_hours' do
    it 'returns 0 when not clocked out' do
      time_entry = create(:time_entry, clock_in_time: 2.hours.ago, clock_out_time: nil)
      expect(time_entry.worked_hours).to eq(0)
    end

    it 'calculates worked hours when clocked out' do
      time_entry = create(:time_entry, clock_in_time: 8.hours.ago, clock_out_time: Time.current)
      expect(time_entry.worked_hours).to be_within(0.1).of(8.0)
    end

    it 'rounds to 2 decimal places' do
      time_entry = create(:time_entry, clock_in_time: 2.hours.ago - 30.minutes, clock_out_time: Time.current)
      expect(time_entry.worked_hours).to eq(2.5)
    end
  end

  describe '#clocked_in?' do
    it 'returns true when clocked in but not clocked out' do
      time_entry = create(:time_entry, clock_in_time: 1.hour.ago, clock_out_time: nil)
      expect(time_entry.clocked_in?).to be true
    end

    it 'returns false when clocked out' do
      time_entry = create(:time_entry, :clocked_out)
      expect(time_entry.clocked_in?).to be false
    end
  end

  describe '#clocked_out?' do
    it 'returns true when clocked out' do
      time_entry = create(:time_entry, :clocked_out)
      expect(time_entry.clocked_out?).to be true
    end

    it 'returns false when not clocked out' do
      time_entry = create(:time_entry, clock_out_time: nil)
      expect(time_entry.clocked_out?).to be false
    end
  end
end
