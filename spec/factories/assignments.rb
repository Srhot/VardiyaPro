# frozen_string_literal: true

FactoryBot.define do
  factory :assignment do
    association :shift
    association :employee, factory: :user
    status { 'pending' }

    trait :pending do
      status { 'pending' }
    end

    trait :confirmed do
      status { 'confirmed' }
    end

    trait :completed do
      status { 'completed' }
    end

    trait :cancelled do
      status { 'cancelled' }
    end
  end
end
