# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'TimeEntries API', type: :request do
  let(:admin) { create(:user, role: 'admin') }
  let(:employee) { create(:user, role: 'employee') }
  let(:other_employee) { create(:user, role: 'employee') }
  let(:admin_token) { JsonWebToken.encode(user_id: admin.id) }
  let(:employee_token) { JsonWebToken.encode(user_id: employee.id) }
  let(:other_employee_token) { JsonWebToken.encode(user_id: other_employee.id) }

  let(:shift) { create(:shift) }
  let(:assignment) { create(:assignment, employee: employee, shift: shift, status: 'confirmed') }
  let(:time_entry) { create(:time_entry, assignment: assignment) }

  describe 'GET /api/v1/time_entries' do
    let!(:employee_time_entry) { create(:time_entry, assignment: create(:assignment, employee: employee, status: 'confirmed')) }
    let!(:other_time_entry) { create(:time_entry, assignment: create(:assignment, employee: other_employee, status: 'confirmed')) }

    context 'as admin' do
      it 'returns all time entries' do
        get '/api/v1/time_entries', headers: { 'Authorization' => "Bearer #{admin_token}" }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['data'].size).to eq(2)
      end
    end

    context 'as employee' do
      it 'returns only own time entries' do
        get '/api/v1/time_entries', headers: { 'Authorization' => "Bearer #{employee_token}" }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['data'].size).to eq(1)
        expect(json['data'][0]['employee']['id']).to eq(employee.id)
      end
    end

    context 'with filters' do
      let!(:clocked_out_entry) { create(:time_entry, :clocked_out, assignment: create(:assignment, employee: admin, status: 'confirmed')) }

      it 'filters by status=clocked_in' do
        get '/api/v1/time_entries?status=clocked_in', headers: { 'Authorization' => "Bearer #{admin_token}" }

        json = JSON.parse(response.body)
        expect(json['data'].all? { |e| e['clock_out_time'].nil? }).to be true
      end

      it 'filters by status=clocked_out' do
        get '/api/v1/time_entries?status=clocked_out', headers: { 'Authorization' => "Bearer #{admin_token}" }

        json = JSON.parse(response.body)
        expect(json['data'].all? { |e| e['clock_out_time'].present? }).to be true
      end
    end
  end

  describe 'GET /api/v1/time_entries/:id' do
    context 'as owner' do
      it 'returns the time entry' do
        get "/api/v1/time_entries/#{time_entry.id}", headers: { 'Authorization' => "Bearer #{employee_token}" }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['data']['id']).to eq(time_entry.id)
      end
    end

    context 'as other employee' do
      it 'returns forbidden' do
        get "/api/v1/time_entries/#{time_entry.id}", headers: { 'Authorization' => "Bearer #{other_employee_token}" }

        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'as admin' do
      it 'returns the time entry' do
        get "/api/v1/time_entries/#{time_entry.id}", headers: { 'Authorization' => "Bearer #{admin_token}" }

        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe 'POST /api/v1/assignments/:assignment_id/clock_in' do
    context 'as assignment owner' do
      it 'creates a time entry and clocks in' do
        expect do
          post "/api/v1/assignments/#{assignment.id}/clock_in",
               params: { notes: 'Starting shift' },
               headers: { 'Authorization' => "Bearer #{employee_token}" }
        end.to change(TimeEntry, :count).by(1)

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json['data']['clock_in_time']).to be_present
        expect(json['data']['clock_out_time']).to be_nil
        expect(json['data']['notes']).to eq('Starting shift')
      end
    end

    context 'when time entry already exists' do
      before { create(:time_entry, assignment: assignment) }

      it 'returns error' do
        post "/api/v1/assignments/#{assignment.id}/clock_in",
             headers: { 'Authorization' => "Bearer #{employee_token}" }

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['errors']).to include('Time entry already exists for this assignment')
      end
    end

    context 'when assignment is not confirmed' do
      let(:pending_assignment) { create(:assignment, employee: employee, status: 'pending') }

      it 'returns error' do
        post "/api/v1/assignments/#{pending_assignment.id}/clock_in",
             headers: { 'Authorization' => "Bearer #{employee_token}" }

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['errors']).to include('Assignment must be confirmed before clocking in')
      end
    end

    context 'as other employee' do
      it 'returns forbidden' do
        post "/api/v1/assignments/#{assignment.id}/clock_in",
             headers: { 'Authorization' => "Bearer #{other_employee_token}" }

        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'PATCH /api/v1/time_entries/:id/clock_out' do
    let!(:clocked_in_entry) { create(:time_entry, assignment: assignment, clock_out_time: nil) }

    context 'as owner' do
      it 'clocks out and completes assignment' do
        patch "/api/v1/time_entries/#{clocked_in_entry.id}/clock_out",
              params: { notes: 'Finished shift' },
              headers: { 'Authorization' => "Bearer #{employee_token}" }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['data']['clock_out_time']).to be_present
        expect(json['data']['worked_hours']).to be > 0

        assignment.reload
        expect(assignment.status).to eq('completed')
        expect(assignment.completed_at).to be_present
      end
    end

    context 'when already clocked out' do
      let!(:clocked_out_entry) { create(:time_entry, :clocked_out, assignment: assignment) }

      it 'returns error' do
        patch "/api/v1/time_entries/#{clocked_out_entry.id}/clock_out",
              headers: { 'Authorization' => "Bearer #{employee_token}" }

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['errors']).to include('Already clocked out')
      end
    end

    context 'as other employee' do
      it 'returns forbidden' do
        patch "/api/v1/time_entries/#{clocked_in_entry.id}/clock_out",
              headers: { 'Authorization' => "Bearer #{other_employee_token}" }

        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'PATCH /api/v1/time_entries/:id' do
    context 'as admin' do
      it 'updates time entry' do
        new_clock_in = 1.hour.ago
        patch "/api/v1/time_entries/#{time_entry.id}",
              params: { clock_in_time: new_clock_in, notes: 'Corrected time' },
              headers: { 'Authorization' => "Bearer #{admin_token}" }

        expect(response).to have_http_status(:ok)
        time_entry.reload
        expect(time_entry.notes).to eq('Corrected time')
      end
    end

    context 'as employee' do
      it 'returns forbidden' do
        patch "/api/v1/time_entries/#{time_entry.id}",
              params: { notes: 'Try to update' },
              headers: { 'Authorization' => "Bearer #{employee_token}" }

        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'DELETE /api/v1/time_entries/:id' do
    context 'as admin' do
      it 'deletes time entry' do
        entry_to_delete = create(:time_entry, assignment: create(:assignment, status: 'confirmed'))

        expect do
          delete "/api/v1/time_entries/#{entry_to_delete.id}",
                 headers: { 'Authorization' => "Bearer #{admin_token}" }
        end.to change(TimeEntry, :count).by(-1)

        expect(response).to have_http_status(:no_content)
      end
    end

    context 'as employee' do
      it 'returns forbidden' do
        delete "/api/v1/time_entries/#{time_entry.id}",
               headers: { 'Authorization' => "Bearer #{employee_token}" }

        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
