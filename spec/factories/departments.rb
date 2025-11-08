# frozen_string_literal: true

FactoryBot.define do
  factory :department do
    sequence(:name) { |n| "Department #{n}" }
    description { Faker::Lorem.sentence }
    active { true }

    trait :inactive do
      active { false }
    end

    trait :engineering do
      name { 'Engineering' }
      description { 'Engineering department' }
    end

    trait :sales do
      name { 'Sales' }
      description { 'Sales department' }
    end

    trait :support do
      name { 'Support' }
      description { 'Customer support department' }
    end
  end
end
