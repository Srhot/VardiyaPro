# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Shifts API', type: :request do
  let(:admin) { create(:user, :admin) }
  let(:employee) { create(:user, :employee) }
  let(:department) { create(:department) }
  let!(:shift) { create(:shift, department: department) }

  describe 'GET /api/v1/shifts' do
    before { create_list(:shift, 5) }

    it 'returns all shifts' do
      get '/api/v1/shifts'
      expect(response).to have_http_status(:ok)
      json = json_response
      expect(json[:data]).to be_an(Array)
    end

    it 'filters by department' do
      get '/api/v1/shifts', params: { department_id: department.id }
      expect(response).to have_http_status(:ok)
      json = json_response
      expect(json[:data].first[:department_id]).to eq(department.id)
    end

    it 'filters by shift type' do
      create(:shift, :morning)
      get '/api/v1/shifts', params: { shift_type: 'morning' }
      json = json_response
      expect(json[:data].map { |s| s[:shift_type] }.uniq).to eq(['morning'])
    end

    it 'searches by query' do
      searchable = create(:shift, department: create(:department, name: 'Special Ops'))
      get '/api/v1/shifts', params: { q: 'special' }
      json = json_response
      expect(json[:data].map { |s| s[:id] }).to include(searchable.id)
    end
  end

  describe 'GET /api/v1/shifts/:id' do
    it 'returns shift details' do
      get "/api/v1/shifts/#{shift.id}"
      expect(response).to have_http_status(:ok)
      json = json_response
      expect(json[:data][:id]).to eq(shift.id)
    end
  end

  describe 'POST /api/v1/shifts' do
    context 'as admin' do
      it 'creates new shift' do
        expect do
          post '/api/v1/shifts', params: {
            shift: {
              department_id: department.id,
              shift_type: 'morning',
              start_time: Time.current.tomorrow.change(hour: 8),
              end_time: Time.current.tomorrow.change(hour: 16),
              required_staff: 2
            }
          }.to_json, headers: auth_headers_for(admin)
        end.to change(Shift, :count).by(1)

        expect(response).to have_http_status(:created)
      end

      it 'validates shift duration' do
        post '/api/v1/shifts', params: {
          shift: {
            department_id: department.id,
            shift_type: 'morning',
            start_time: Time.current,
            end_time: Time.current + 2.hours, # Too short
            required_staff: 2
          }
        }.to_json, headers: auth_headers_for(admin)

        expect(response).to have_http_status(:unprocessable_entity)
        json = json_response
        expect(json[:errors]).to include(/at least 4 hours/)
      end
    end

    context 'as employee' do
      it 'returns forbidden' do
        post '/api/v1/shifts', params: {
          shift: { department_id: department.id }
        }.to_json, headers: auth_headers_for(employee)

        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'PATCH /api/v1/shifts/:id' do
    context 'as admin' do
      it 'updates shift' do
        patch "/api/v1/shifts/#{shift.id}", params: {
          shift: { required_staff: 5 }
        }.to_json, headers: auth_headers_for(admin)

        expect(response).to have_http_status(:ok)
        expect(shift.reload.required_staff).to eq(5)
      end
    end
  end

  describe 'DELETE /api/v1/shifts/:id' do
    context 'as admin' do
      it 'deletes shift' do
        delete_shift = create(:shift)
        expect do
          delete "/api/v1/shifts/#{delete_shift.id}", headers: auth_headers_for(admin)
        end.to change(Shift, :count).by(-1)

        expect(response).to have_http_status(:no_content)
      end
    end
  end
end
