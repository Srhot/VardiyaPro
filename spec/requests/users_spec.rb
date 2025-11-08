# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Users API', type: :request do
  let(:admin) { create(:user, :admin) }
  let(:hr_user) { create(:user, :hr) }
  let(:manager) { create(:user, :manager) }
  let(:employee) { create(:user, :employee) }
  let(:department) { create(:department) }

  describe 'GET /api/v1/users' do
    before do
      create_list(:user, 5)
    end

    context 'as admin' do
      it 'returns all users' do
        get '/api/v1/users', headers: auth_headers_for(admin)
        expect(response).to have_http_status(:ok)
        json = json_response
        expect(json[:data]).to be_an(Array)
        expect(json[:meta]).to be_present
      end

      it 'searches users by name' do
        user = create(:user, name: 'John Doe')
        get '/api/v1/users', params: { q: 'john' }, headers: auth_headers_for(admin)
        expect(response).to have_http_status(:ok)
        json = json_response
        expect(json[:data].map { |u| u[:id] }).to include(user.id)
      end
    end

    context 'as employee' do
      it 'returns only own profile' do
        get '/api/v1/users', headers: auth_headers_for(employee)
        expect(response).to have_http_status(:ok)
        json = json_response
        expect(json[:data].length).to eq(1)
        expect(json[:data].first[:id]).to eq(employee.id)
      end
    end

    context 'without authentication' do
      it 'returns unauthorized' do
        get '/api/v1/users'
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'GET /api/v1/users/:id' do
    context 'as admin' do
      it 'returns user details' do
        get "/api/v1/users/#{employee.id}", headers: auth_headers_for(admin)
        expect(response).to have_http_status(:ok)
        json = json_response
        expect(json[:data][:id]).to eq(employee.id)
        expect(json[:data][:email]).to eq(employee.email)
      end
    end

    context 'as employee viewing own profile' do
      it 'returns own profile' do
        get "/api/v1/users/#{employee.id}", headers: auth_headers_for(employee)
        expect(response).to have_http_status(:ok)
      end
    end

    context 'as employee viewing another user' do
      let(:other_user) { create(:user) }

      it 'returns forbidden' do
        get "/api/v1/users/#{other_user.id}", headers: auth_headers_for(employee)
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'POST /api/v1/users' do
    context 'as admin' do
      it 'creates new user' do
        expect {
          post '/api/v1/users', params: {
            user: {
              email: 'newuser@example.com',
              name: 'New User',
              role: 'employee',
              password: 'password123',
              password_confirmation: 'password123'
            }
          }.to_json, headers: auth_headers_for(admin)
        }.to change(User, :count).by(1)

        expect(response).to have_http_status(:created)
      end
    end

    context 'as employee' do
      it 'returns forbidden' do
        post '/api/v1/users', params: {
          user: { email: 'test@example.com', name: 'Test', role: 'employee' }
        }.to_json, headers: auth_headers_for(employee)

        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'PATCH /api/v1/users/:id' do
    context 'as admin' do
      it 'updates user' do
        patch "/api/v1/users/#{employee.id}", params: {
          user: { name: 'Updated Name' }
        }.to_json, headers: auth_headers_for(admin)

        expect(response).to have_http_status(:ok)
        expect(employee.reload.name).to eq('Updated Name')
      end
    end

    context 'as employee updating own profile' do
      it 'updates allowed fields' do
        patch "/api/v1/users/#{employee.id}", params: {
          user: { name: 'New Name' }
        }.to_json, headers: auth_headers_for(employee)

        expect(response).to have_http_status(:ok)
        expect(employee.reload.name).to eq('New Name')
      end
    end
  end

  describe 'PATCH /api/v1/users/:id/update_password' do
    context 'with correct current password' do
      it 'updates password' do
        patch "/api/v1/users/#{employee.id}/update_password", params: {
          current_password: 'password123',
          new_password: 'newpassword123',
          password_confirmation: 'newpassword123'
        }.to_json, headers: auth_headers_for(employee)

        expect(response).to have_http_status(:ok)
        expect(employee.reload.authenticate('newpassword123')).to be_truthy
      end
    end

    context 'with incorrect current password' do
      it 'returns unauthorized' do
        patch "/api/v1/users/#{employee.id}/update_password", params: {
          current_password: 'wrong_password',
          new_password: 'newpassword123',
          password_confirmation: 'newpassword123'
        }.to_json, headers: auth_headers_for(employee)

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'POST /api/v1/users/:id/activate' do
    let(:inactive_user) { create(:user, :inactive) }

    context 'as admin' do
      it 'activates user' do
        post "/api/v1/users/#{inactive_user.id}/activate", headers: auth_headers_for(admin)
        expect(response).to have_http_status(:ok)
        expect(inactive_user.reload.active).to be true
      end
    end

    context 'as employee' do
      it 'returns forbidden' do
        post "/api/v1/users/#{inactive_user.id}/activate", headers: auth_headers_for(employee)
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
