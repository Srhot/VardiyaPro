# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Holiday, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:date) }

    describe 'uniqueness' do
      let!(:existing_holiday) { create(:holiday, date: Date.new(2025, 12, 25)) }

      it 'validates uniqueness of date' do
        duplicate = build(:holiday, date: Date.new(2025, 12, 25))
        expect(duplicate).not_to be_valid
        expect(duplicate.errors[:date]).to include('has already been taken')
      end
    end
  end

  describe 'scopes' do
    let!(:past_holiday) { create(:holiday, :past, date: 1.month.ago.to_date) }
    let!(:today_holiday) { create(:holiday, :today, date: Date.current) }
    let!(:upcoming_holiday) { create(:holiday, :upcoming, date: 1.month.from_now.to_date) }

    describe '.upcoming' do
      it 'returns holidays from today onwards' do
        expect(Holiday.upcoming).to include(today_holiday, upcoming_holiday)
        expect(Holiday.upcoming).not_to include(past_holiday)
      end

      it 'orders by date ascending' do
        expect(Holiday.upcoming.first).to eq(today_holiday)
      end
    end

    describe '.past' do
      it 'returns holidays before today' do
        expect(Holiday.past).to include(past_holiday)
        expect(Holiday.past).not_to include(today_holiday, upcoming_holiday)
      end

      it 'orders by date descending' do
        past_holiday2 = create(:holiday, date: 2.months.ago.to_date)
        expect(Holiday.past.first).to eq(past_holiday)
      end
    end

    describe '.for_year' do
      let!(:holiday_2025) { create(:holiday, date: Date.new(2025, 5, 1)) }
      let!(:holiday_2024) { create(:holiday, date: Date.new(2024, 5, 1)) }

      it 'returns holidays for specified year' do
        expect(Holiday.for_year(2025)).to include(holiday_2025)
        expect(Holiday.for_year(2025)).not_to include(holiday_2024)
      end
    end

    describe '.for_month' do
      let!(:january_holiday) { create(:holiday, date: Date.new(2025, 1, 1)) }
      let!(:february_holiday) { create(:holiday, date: Date.new(2025, 2, 14)) }

      it 'returns holidays for specified year and month' do
        expect(Holiday.for_month(2025, 1)).to include(january_holiday)
        expect(Holiday.for_month(2025, 1)).not_to include(february_holiday)
      end
    end
  end

  describe '.is_holiday?' do
    let!(:holiday) { create(:holiday, date: Date.new(2025, 12, 25)) }

    it 'returns true when date is a holiday' do
      expect(Holiday.is_holiday?(Date.new(2025, 12, 25))).to be true
    end

    it 'returns false when date is not a holiday' do
      expect(Holiday.is_holiday?(Date.new(2025, 12, 24))).to be false
    end
  end

  describe '.holidays_between' do
    let!(:holiday1) { create(:holiday, date: Date.new(2025, 1, 1)) }
    let!(:holiday2) { create(:holiday, date: Date.new(2025, 1, 15)) }
    let!(:holiday3) { create(:holiday, date: Date.new(2025, 2, 1)) }

    it 'returns holidays within date range' do
      start_date = Date.new(2025, 1, 1)
      end_date = Date.new(2025, 1, 31)
      holidays = Holiday.holidays_between(start_date, end_date)

      expect(holidays).to include(holiday1, holiday2)
      expect(holidays).not_to include(holiday3)
    end

    it 'orders results by date' do
      holidays = Holiday.holidays_between(Date.new(2025, 1, 1), Date.new(2025, 1, 31))
      expect(holidays.first).to eq(holiday1)
      expect(holidays.last).to eq(holiday2)
    end
  end

  describe 'instance methods' do
    describe '#past?' do
      it 'returns true for past dates' do
        holiday = build(:holiday, date: 1.day.ago.to_date)
        expect(holiday.past?).to be true
      end

      it 'returns false for future dates' do
        holiday = build(:holiday, date: 1.day.from_now.to_date)
        expect(holiday.past?).to be false
      end
    end

    describe '#upcoming?' do
      it 'returns true for today and future dates' do
        holiday = build(:holiday, date: Date.current)
        expect(holiday.upcoming?).to be true

        holiday.date = 1.day.from_now.to_date
        expect(holiday.upcoming?).to be true
      end

      it 'returns false for past dates' do
        holiday = build(:holiday, date: 1.day.ago.to_date)
        expect(holiday.upcoming?).to be false
      end
    end

    describe '#today?' do
      it 'returns true when date is today' do
        holiday = build(:holiday, date: Date.current)
        expect(holiday.today?).to be true
      end

      it 'returns false when date is not today' do
        holiday = build(:holiday, date: 1.day.ago.to_date)
        expect(holiday.today?).to be false

        holiday.date = 1.day.from_now.to_date
        expect(holiday.today?).to be false
      end
    end
  end
end
