# frozen_string_literal: true

FactoryBot.define do
  factory :shift do
    association :department
    shift_type { 'morning' }
    start_time { Time.current.tomorrow.change(hour: 8, min: 0) }
    end_time { start_time + 8.hours }
    required_staff { 2 }
    description { Faker::Lorem.sentence }
    active { true }

    trait :morning do
      shift_type { 'morning' }
      start_time { Time.current.tomorrow.change(hour: 8, min: 0) }
      end_time { Time.current.tomorrow.change(hour: 16, min: 0) }
    end

    trait :afternoon do
      shift_type { 'afternoon' }
      start_time { Time.current.tomorrow.change(hour: 14, min: 0) }
      end_time { Time.current.tomorrow.change(hour: 22, min: 0) }
    end

    trait :evening do
      shift_type { 'evening' }
      start_time { Time.current.tomorrow.change(hour: 16, min: 0) }
      end_time { Time.current.tomorrow.change(hour: 23, min: 0) }
    end

    trait :night do
      shift_type { 'night' }
      start_time { Time.current.tomorrow.change(hour: 0, min: 0) }
      end_time { Time.current.tomorrow.change(hour: 8, min: 0) }
    end

    trait :flexible do
      shift_type { 'flexible' }
      start_time { Time.current.tomorrow.change(hour: 9, min: 0) }
      end_time { Time.current.tomorrow.change(hour: 17, min: 0) }
    end

    trait :on_call do
      shift_type { 'on_call' }
      start_time { Time.current.tomorrow.change(hour: 0, min: 0) }
      end_time { Time.current.tomorrow.change(hour: 12, min: 0) }
    end

    trait :inactive do
      active { false }
    end

    trait :short_duration do
      start_time { Time.current.tomorrow.change(hour: 8, min: 0) }
      end_time { Time.current.tomorrow.change(hour: 12, min: 0) }
    end

    trait :long_duration do
      start_time { Time.current.tomorrow.change(hour: 8, min: 0) }
      end_time { Time.current.tomorrow.change(hour: 20, min: 0) }
    end
  end
end
