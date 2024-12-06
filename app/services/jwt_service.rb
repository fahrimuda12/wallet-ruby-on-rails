class JwtService
  # SECRET_KEY = Rails.application.secrets.secret_key_base. to_s
  SECRET_KEY = Rails.application.credentials.secret_key_base

  print SECRET_KEY

  # Encode payload menjadi JWT
  def self.encode(payload, exp = 24.hours.from_now)
    payload[:exp] = exp.to_i
    JWT.encode(payload, SECRET_KEY)
  end

  # Decode JWT menjadi payload
  def self.decode(token)
    decoded = JWT.decode(token, SECRET_KEY)[0]
    HashWithIndifferentAccess.new(decoded)
  rescue JWT::DecodeError
    nil
  end
end
