# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Assignments API', type: :request do
  let(:admin) { create(:user, :admin) }
  let(:employee) { create(:user, :employee) }
  let(:shift) { create(:shift, required_staff: 3) }
  let!(:assignment) { create(:assignment, shift: shift, employee: employee) }

  describe 'GET /api/v1/assignments' do
    before { create_list(:assignment, 5) }

    it 'returns all assignments' do
      get '/api/v1/assignments'
      expect(response).to have_http_status(:ok)
      json = json_response
      expect(json[:data]).to be_an(Array)
    end

    it 'filters by employee' do
      get '/api/v1/assignments', params: { employee_id: employee.id }
      json = json_response
      expect(json[:data].first[:employee_id]).to eq(employee.id)
    end

    it 'filters by status' do
      create(:assignment, :confirmed)
      get '/api/v1/assignments', params: { status: 'confirmed' }
      json = json_response
      expect(json[:data].map { |a| a[:status] }.uniq).to eq(['confirmed'])
    end
  end

  describe 'POST /api/v1/assignments' do
    context 'as admin' do
      let(:new_employee) { create(:user) }

      it 'creates assignment' do
        expect do
          post '/api/v1/assignments', params: {
            assignment: {
              shift_id: shift.id,
              employee_id: new_employee.id,
              status: 'pending'
            }
          }.to_json, headers: auth_headers_for(admin)
        end.to change(Assignment, :count).by(1)

        expect(response).to have_http_status(:created)
      end

      it 'prevents overlapping assignments (CRITICAL TEST)' do
        # Create shift1 and assign employee
        shift1 = create(:shift, start_time: Time.current, end_time: Time.current + 8.hours)
        create(:assignment, shift: shift1, employee: employee, status: 'confirmed')

        # Try to create overlapping shift2 assignment
        shift2 = create(:shift, start_time: Time.current + 4.hours, end_time: Time.current + 12.hours)

        post '/api/v1/assignments', params: {
          assignment: {
            shift_id: shift2.id,
            employee_id: employee.id,
            status: 'pending'
          }
        }.to_json, headers: auth_headers_for(admin)

        expect(response).to have_http_status(:unprocessable_entity)
        json = json_response
        expect(json[:errors].first).to include('overlapping shift')
      end

      it 'prevents overfilling shifts' do
        # Fill shift to capacity
        shift_full = create(:shift, required_staff: 1)
        create(:assignment, :confirmed, shift: shift_full)

        # Try to add another
        post '/api/v1/assignments', params: {
          assignment: {
            shift_id: shift_full.id,
            employee_id: create(:user).id,
            status: 'pending'
          }
        }.to_json, headers: auth_headers_for(admin)

        expect(response).to have_http_status(:unprocessable_entity)
        json = json_response
        expect(json[:errors].first).to include('already full')
      end
    end
  end

  describe 'PATCH /api/v1/assignments/:id/confirm' do
    context 'as admin' do
      it 'confirms assignment' do
        pending_assignment = create(:assignment, :pending)
        patch "/api/v1/assignments/#{pending_assignment.id}/confirm", headers: auth_headers_for(admin)

        expect(response).to have_http_status(:ok)
        expect(pending_assignment.reload.status).to eq('confirmed')
      end
    end
  end

  describe 'PATCH /api/v1/assignments/:id/cancel' do
    context 'as admin' do
      it 'cancels assignment' do
        patch "/api/v1/assignments/#{assignment.id}/cancel", headers: auth_headers_for(admin)

        expect(response).to have_http_status(:ok)
        expect(assignment.reload.status).to eq('cancelled')
      end
    end
  end
end
