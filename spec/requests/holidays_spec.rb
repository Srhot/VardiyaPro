# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Holidays API', type: :request do
  let(:admin) { create(:user, role: 'admin') }
  let(:employee) { create(:user, role: 'employee') }
  let(:admin_token) { JsonWebToken.encode(user_id: admin.id) }
  let(:employee_token) { JsonWebToken.encode(user_id: employee.id) }

  describe 'GET /api/v1/holidays' do
    let!(:past_holiday) { create(:holiday, :past, date: 1.month.ago.to_date, name: 'Past Holiday') }
    let!(:upcoming_holiday) { create(:holiday, :upcoming, date: 1.month.from_now.to_date, name: 'Future Holiday') }

    context 'as authenticated user' do
      it 'returns all holidays' do
        get '/api/v1/holidays', headers: { 'Authorization' => "Bearer #{employee_token}" }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['data'].size).to eq(2)
      end
    end

    context 'with filters' do
      it 'filters by upcoming=true' do
        get '/api/v1/holidays?upcoming=true', headers: { 'Authorization' => "Bearer #{employee_token}" }

        json = JSON.parse(response.body)
        expect(json['data'].all? { |h| h['is_upcoming'] }).to be true
      end

      it 'filters by past=true' do
        get '/api/v1/holidays?past=true', headers: { 'Authorization' => "Bearer #{employee_token}" }

        json = JSON.parse(response.body)
        expect(json['data'].all? { |h| h['is_past'] }).to be true
      end

      it 'filters by year' do
        holiday_2025 = create(:holiday, date: Date.new(2025, 5, 1))
        get '/api/v1/holidays?year=2025', headers: { 'Authorization' => "Bearer #{employee_token}" }

        json = JSON.parse(response.body)
        expect(json['data'].any? { |h| h['id'] == holiday_2025.id }).to be true
      end

      it 'filters by year and month' do
        january_holiday = create(:holiday, date: Date.new(2025, 1, 1))
        get '/api/v1/holidays?year=2025&month=1', headers: { 'Authorization' => "Bearer #{employee_token}" }

        json = JSON.parse(response.body)
        expect(json['data'].any? { |h| h['id'] == january_holiday.id }).to be true
      end
    end
  end

  describe 'GET /api/v1/holidays/:id' do
    let(:holiday) { create(:holiday) }

    it 'returns the holiday' do
      get "/api/v1/holidays/#{holiday.id}", headers: { 'Authorization' => "Bearer #{employee_token}" }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['id']).to eq(holiday.id)
      expect(json['data']['name']).to eq(holiday.name)
      expect(json['data']['date']).to eq(holiday.date.to_s)
    end

    it 'returns not_found for invalid id' do
      get '/api/v1/holidays/99999', headers: { 'Authorization' => "Bearer #{employee_token}" }

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST /api/v1/holidays' do
    context 'as admin' do
      it 'creates a new holiday' do
        expect do
          post '/api/v1/holidays',
               params: { name: 'New Year', date: '2025-01-01' },
               headers: { 'Authorization' => "Bearer #{admin_token}" }
        end.to change(Holiday, :count).by(1)

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json['data']['name']).to eq('New Year')
        expect(json['data']['date']).to eq('2025-01-01')
      end

      it 'returns error for invalid data' do
        post '/api/v1/holidays',
             params: { name: '', date: '2025-01-01' },
             headers: { 'Authorization' => "Bearer #{admin_token}" }

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['errors']).to be_present
      end

      it 'returns error for duplicate date' do
        create(:holiday, date: '2025-01-01')

        post '/api/v1/holidays',
             params: { name: 'Another Holiday', date: '2025-01-01' },
             headers: { 'Authorization' => "Bearer #{admin_token}" }

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['errors']).to include('Date has already been taken')
      end
    end

    context 'as employee' do
      it 'returns forbidden' do
        post '/api/v1/holidays',
             params: { name: 'Holiday', date: '2025-01-01' },
             headers: { 'Authorization' => "Bearer #{employee_token}" }

        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'PATCH /api/v1/holidays/:id' do
    let(:holiday) { create(:holiday, name: 'Old Name') }

    context 'as admin' do
      it 'updates the holiday' do
        patch "/api/v1/holidays/#{holiday.id}",
              params: { name: 'Updated Name' },
              headers: { 'Authorization' => "Bearer #{admin_token}" }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['data']['name']).to eq('Updated Name')

        holiday.reload
        expect(holiday.name).to eq('Updated Name')
      end

      it 'returns error for invalid data' do
        patch "/api/v1/holidays/#{holiday.id}",
              params: { name: '' },
              headers: { 'Authorization' => "Bearer #{admin_token}" }

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'as employee' do
      it 'returns forbidden' do
        patch "/api/v1/holidays/#{holiday.id}",
              params: { name: 'Updated' },
              headers: { 'Authorization' => "Bearer #{employee_token}" }

        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'DELETE /api/v1/holidays/:id' do
    let!(:holiday) { create(:holiday) }

    context 'as admin' do
      it 'deletes the holiday' do
        expect do
          delete "/api/v1/holidays/#{holiday.id}",
                 headers: { 'Authorization' => "Bearer #{admin_token}" }
        end.to change(Holiday, :count).by(-1)

        expect(response).to have_http_status(:no_content)
      end
    end

    context 'as employee' do
      it 'returns forbidden' do
        delete "/api/v1/holidays/#{holiday.id}",
               headers: { 'Authorization' => "Bearer #{employee_token}" }

        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'GET /api/v1/holidays/check' do
    let!(:holiday) { create(:holiday, date: Date.current, name: 'Today Holiday') }

    context 'checking a holiday date' do
      it 'returns true with holiday details' do
        get "/api/v1/holidays/check?date=#{Date.current}",
            headers: { 'Authorization' => "Bearer #{employee_token}" }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['is_holiday']).to be true
        expect(json['holiday']['name']).to eq('Today Holiday')
      end
    end

    context 'checking a non-holiday date' do
      it 'returns false' do
        get "/api/v1/holidays/check?date=#{1.year.from_now.to_date}",
            headers: { 'Authorization' => "Bearer #{employee_token}" }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['is_holiday']).to be false
        expect(json['holiday']).to be_nil
      end
    end

    context 'without date parameter' do
      it 'checks today by default' do
        get '/api/v1/holidays/check',
            headers: { 'Authorization' => "Bearer #{employee_token}" }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['is_holiday']).to be true
      end
    end

    context 'with invalid date format' do
      it 'returns bad request' do
        get '/api/v1/holidays/check?date=invalid-date',
            headers: { 'Authorization' => "Bearer #{employee_token}" }

        expect(response).to have_http_status(:bad_request)
        json = JSON.parse(response.body)
        expect(json['errors']).to include('Invalid date format. Use YYYY-MM-DD')
      end
    end
  end
end
