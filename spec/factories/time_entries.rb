# frozen_string_literal: true

FactoryBot.define do
  factory :time_entry do
    association :assignment

    clock_in_time { 2.hours.ago }
    clock_out_time { nil }
    notes { nil }

    trait :clocked_out do
      clock_out_time { Time.current }
    end

    trait :with_notes do
      notes { Faker::Lorem.sentence }
    end

    trait :yesterday do
      clock_in_time { 1.day.ago.beginning_of_day + 8.hours }
      clock_out_time { 1.day.ago.beginning_of_day + 16.hours }
    end

    trait :long_shift do
      clock_in_time { 10.hours.ago }
      clock_out_time { Time.current }
    end
  end
end
