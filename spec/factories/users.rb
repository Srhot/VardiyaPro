# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@vardiyapro.com" }
    sequence(:name) { |n| "Test User #{n}" }
    password { 'password123' }
    password_confirmation { 'password123' }
    role { 'employee' }
    active { true }
    phone { Faker::PhoneNumber.phone_number }
    association :department

    trait :admin do
      role { 'admin' }
      email { 'admin@vardiyapro.com' }
      name { 'Admin User' }
    end

    trait :manager do
      role { 'manager' }
      email { 'manager@vardiyapro.com' }
      name { 'Manager User' }
    end

    trait :hr do
      role { 'hr' }
      email { 'hr@vardiyapro.com' }
      name { 'HR User' }
    end

    trait :employee do
      role { 'employee' }
    end

    trait :inactive do
      active { false }
    end

    trait :without_department do
      department { nil }
    end
  end
end
