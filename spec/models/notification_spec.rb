# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Notification, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:related).optional }
  end

  describe 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:message) }
    it { should validate_presence_of(:notification_type) }
    it { should validate_inclusion_of(:notification_type).in_array(Notification::NOTIFICATION_TYPES) }
  end

  describe 'scopes' do
    let!(:unread_notification) { create(:notification, read: false) }
    let!(:read_notification) { create(:notification, read: true) }
    let(:user) { create(:user) }
    let!(:user_notification) { create(:notification, user: user) }

    describe '.unread' do
      it 'returns only unread notifications' do
        expect(Notification.unread).to include(unread_notification)
        expect(Notification.unread).not_to include(read_notification)
      end
    end

    describe '.read' do
      it 'returns only read notifications' do
        expect(Notification.read).to include(read_notification)
        expect(Notification.read).not_to include(unread_notification)
      end
    end

    describe '.by_type' do
      let!(:shift_assigned) { create(:notification, notification_type: 'shift_assigned') }
      let!(:shift_cancelled) { create(:notification, notification_type: 'shift_cancelled') }

      it 'filters by notification type' do
        expect(Notification.by_type('shift_assigned')).to include(shift_assigned)
        expect(Notification.by_type('shift_assigned')).not_to include(shift_cancelled)
      end
    end

    describe '.for_user' do
      it 'filters notifications by user' do
        expect(Notification.for_user(user.id)).to include(user_notification)
        expect(Notification.for_user(user.id)).not_to include(unread_notification)
      end
    end
  end

  describe 'instance methods' do
    describe '#mark_as_read!' do
      let(:notification) { create(:notification, read: false) }

      it 'marks notification as read' do
        notification.mark_as_read!
        expect(notification.reload.read).to be true
      end
    end

    describe '#mark_as_unread!' do
      let(:notification) { create(:notification, read: true) }

      it 'marks notification as unread' do
        notification.mark_as_unread!
        expect(notification.reload.read).to be false
      end
    end
  end

  describe 'class methods' do
    let(:user) { create(:user) }
    let!(:unread1) { create(:notification, user: user, read: false) }
    let!(:unread2) { create(:notification, user: user, read: false) }
    let!(:read_notif) { create(:notification, user: user, read: true) }

    describe '.mark_all_as_read' do
      it 'marks all unread notifications for user as read' do
        Notification.mark_all_as_read(user.id)
        expect(unread1.reload.read).to be true
        expect(unread2.reload.read).to be true
        expect(read_notif.reload.read).to be true
      end
    end
  end
end
