# frozen_string_literal: true

module RequestSpecHelper
  # Generate JWT token for testing
  def auth_token_for(user)
    JsonWebToken.encode(user_id: user.id)
  end

  # Generate headers with JWT token
  def auth_headers_for(user)
    token = auth_token_for(user)
    {
      'Authorization' => "Bearer #{token}",
      'Content-Type' => 'application/json'
    }
  end

  # Parse JSON response
  def json_response
    JSON.parse(response.body, symbolize_names: true)
  end

  # Helper to create authenticated user
  def authenticated_user(role: 'employee', **attributes)
    create(:user, role: role, **attributes)
  end
end
