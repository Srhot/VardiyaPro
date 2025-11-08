# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Authentication API', type: :request do
  describe 'POST /api/v1/auth/login' do
    let(:user) { create(:user, email: 'test@example.com', password: 'password123') }

    context 'with valid credentials' do
      it 'returns JWT token and user data' do
        post '/api/v1/auth/login', params: {
          email: user.email,
          password: 'password123'
        }.to_json, headers: { 'Content-Type' => 'application/json' }

        expect(response).to have_http_status(:ok)
        json = json_response
        expect(json[:token]).to be_present
        expect(json[:user][:email]).to eq(user.email)
        expect(json[:user][:name]).to eq(user.name)
      end
    end

    context 'with invalid password' do
      it 'returns unauthorized error' do
        post '/api/v1/auth/login', params: {
          email: user.email,
          password: 'wrong_password'
        }.to_json, headers: { 'Content-Type' => 'application/json' }

        expect(response).to have_http_status(:unauthorized)
        json = json_response
        expect(json[:errors]).to include('Invalid email or password')
      end
    end

    context 'with non-existent email' do
      it 'returns unauthorized error' do
        post '/api/v1/auth/login', params: {
          email: 'nonexistent@example.com',
          password: 'password123'
        }.to_json, headers: { 'Content-Type' => 'application/json' }

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'with inactive user' do
      it 'returns unauthorized error' do
        inactive_user = create(:user, :inactive, password: 'password123')
        post '/api/v1/auth/login', params: {
          email: inactive_user.email,
          password: 'password123'
        }.to_json, headers: { 'Content-Type' => 'application/json' }

        expect(response).to have_http_status(:unauthorized)
        json = json_response
        expect(json[:errors]).to include('Account is not active')
      end
    end
  end
end
