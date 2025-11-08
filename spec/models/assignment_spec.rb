# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Assignment, type: :model do
  describe 'associations' do
    it { should belong_to(:shift) }
    it { should belong_to(:employee).class_name('User') }
  end

  describe 'validations' do
    subject { build(:assignment) }

    it { should validate_presence_of(:status) }
    it { should validate_inclusion_of(:status).in_array(Assignment::STATUSES) }

    describe 'employee uniqueness per shift' do
      let(:shift) { create(:shift) }
      let(:employee) { create(:user) }

      it 'prevents duplicate assignments to same shift' do
        create(:assignment, shift: shift, employee: employee)
        duplicate = build(:assignment, shift: shift, employee: employee)
        expect(duplicate).not_to be_valid
        expect(duplicate.errors[:employee_id]).to include('already assigned to this shift')
      end
    end

    describe 'no_overlapping_assignments validation (CRITICAL)' do
      let(:employee) { create(:user) }
      let(:shift1) { create(:shift, start_time: Time.current, end_time: Time.current + 8.hours) }
      let(:shift2) { create(:shift, start_time: Time.current + 4.hours, end_time: Time.current + 12.hours) }
      let(:shift3) { create(:shift, start_time: Time.current + 10.hours, end_time: Time.current + 18.hours) }

      it 'prevents overlapping shift assignments' do
        # Create first assignment
        create(:assignment, shift: shift1, employee: employee, status: 'confirmed')

        # Try to create overlapping assignment
        overlapping = build(:assignment, shift: shift2, employee: employee)
        expect(overlapping).not_to be_valid
        expect(overlapping.errors[:base]).to include(/already assigned to an overlapping shift/)
      end

      it 'allows non-overlapping shift assignments' do
        # Create first assignment
        create(:assignment, shift: shift1, employee: employee, status: 'confirmed')

        # Create non-overlapping assignment
        non_overlapping = build(:assignment, shift: shift3, employee: employee)
        expect(non_overlapping).to be_valid
      end

      it 'does not check overlap for cancelled assignments' do
        # Create cancelled assignment
        create(:assignment, shift: shift1, employee: employee, status: 'cancelled')

        # Should allow overlapping assignment since first is cancelled
        overlapping = build(:assignment, shift: shift2, employee: employee)
        expect(overlapping).to be_valid
      end

      it 'checks overlap for pending assignments' do
        # Create pending assignment
        create(:assignment, shift: shift1, employee: employee, status: 'pending')

        # Should not allow overlapping assignment
        overlapping = build(:assignment, shift: shift2, employee: employee)
        expect(overlapping).not_to be_valid
      end
    end

    describe 'shift_not_overfilled validation' do
      let(:shift) { create(:shift, required_staff: 2) }

      it 'prevents creating assignment when shift is full' do
        # Create 2 confirmed assignments (shift requires 2)
        create(:assignment, :confirmed, shift: shift)
        create(:assignment, :confirmed, shift: shift)

        # Try to create another assignment
        overfilled = build(:assignment, shift: shift)
        expect(overfilled).not_to be_valid
        expect(overfilled.errors[:base]).to include(/Shift is already full/)
      end

      it 'allows assignment when shift has available slots' do
        create(:assignment, :confirmed, shift: shift)
        new_assignment = build(:assignment, shift: shift)
        expect(new_assignment).to be_valid
      end
    end
  end

  describe 'scopes' do
    let!(:pending_assignment) { create(:assignment, :pending) }
    let!(:confirmed_assignment) { create(:assignment, :confirmed) }
    let!(:completed_assignment) { create(:assignment, :completed) }
    let!(:cancelled_assignment) { create(:assignment, :cancelled) }

    describe '.pending' do
      it 'returns only pending assignments' do
        expect(Assignment.pending).to include(pending_assignment)
        expect(Assignment.pending).not_to include(confirmed_assignment)
      end
    end

    describe '.confirmed' do
      it 'returns only confirmed assignments' do
        expect(Assignment.confirmed).to include(confirmed_assignment)
        expect(Assignment.confirmed).not_to include(pending_assignment)
      end
    end

    describe '.completed' do
      it 'returns only completed assignments' do
        expect(Assignment.completed).to include(completed_assignment)
        expect(Assignment.completed).not_to include(confirmed_assignment)
      end
    end

    describe '.active' do
      it 'returns pending and confirmed assignments' do
        expect(Assignment.active).to include(pending_assignment, confirmed_assignment)
        expect(Assignment.active).not_to include(cancelled_assignment, completed_assignment)
      end
    end
  end

  describe 'callbacks' do
    describe 'after_create :notify_employee' do
      it 'sends notification when assignment is created' do
        expect(NotificationService).to receive(:notify_shift_assigned)
        create(:assignment)
      end
    end

    describe 'after_update :notify_status_change' do
      let(:assignment) { create(:assignment, :pending) }

      it 'sends confirmation notification when status changes to confirmed' do
        expect(NotificationService).to receive(:notify_assignment_confirmed).with(assignment)
        assignment.update(status: 'confirmed')
      end

      it 'sends cancellation notification when status changes to cancelled' do
        expect(NotificationService).to receive(:notify_assignment_cancelled).with(assignment)
        assignment.update(status: 'cancelled')
      end

      it 'does not send notification when other attributes change' do
        expect(NotificationService).not_to receive(:notify_assignment_confirmed)
        expect(NotificationService).not_to receive(:notify_assignment_cancelled)
        assignment.update(updated_at: Time.current)
      end
    end
  end

  describe 'Auditable concern' do
    it 'includes Auditable module' do
      expect(Assignment.included_modules).to include(Auditable)
    end
  end
end
