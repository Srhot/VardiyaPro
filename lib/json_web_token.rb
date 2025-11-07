class JsonWebToken
  # Encode user data into JWT token
  def self.encode(payload, exp = Rails.application.config.jwt_expiry.from_now)
    payload[:exp] = exp.to_i
    JWT.encode(payload, Rails.application.config.jwt_secret)
  end

  # Decode JWT token and return user data
  def self.decode(token)
    decoded = JWT.decode(token, Rails.application.config.jwt_secret)[0]
    HashWithIndifferentAccess.new(decoded)
  rescue JWT::DecodeError => e
    nil
  end
end
