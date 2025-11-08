# frozen_string_literal: true

FactoryBot.define do
  factory :holiday do
    name { Faker::Holiday.unique.name }
    date { Faker::Date.forward(days: 30) }

    trait :past do
      date { Faker::Date.backward(days: 30) }
    end

    trait :today do
      date { Date.current }
    end

    trait :upcoming do
      date { Faker::Date.forward(days: 60) }
    end

    trait :new_year do
      name { 'New Year\'s Day' }
      date { Date.new(Date.current.year, 1, 1) }
    end

    trait :christmas do
      name { 'Christmas' }
      date { Date.new(Date.current.year, 12, 25) }
    end
  end
end
