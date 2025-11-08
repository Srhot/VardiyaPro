# frozen_string_literal: true

FactoryBot.define do
  factory :notification do
    association :user
    title { 'Test Notification' }
    message { 'This is a test notification' }
    notification_type { 'shift_assigned' }
    read { false }

    trait :unread do
      read { false }
    end

    trait :read do
      read { true }
    end

    trait :shift_assigned do
      notification_type { 'shift_assigned' }
      title { 'New Shift Assignment' }
    end

    trait :shift_confirmed do
      notification_type { 'shift_confirmed' }
      title { 'Shift Confirmed' }
    end

    trait :with_shift do
      association :related, factory: :shift
    end
  end
end
