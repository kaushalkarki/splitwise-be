require 'jwt'

class JsonWebToken
  SECRET_KEY = Rails.application.secrets.secret_key_base.to_s

  def self.encode(payload, exp = 24.hours.from_now)
    payload[:exp] = exp.to_i
    JWT.encode(payload, SECRET_KEY, 'HS256')
  end

  def self.decode(token)
    begin
      decoded = JWT.decode(token, SECRET_KEY, true, algorithm: 'HS256')
      HashWithIndifferentAccess.new decoded.first
    rescue JWT::ExpiredSignature
      Rails.logger.info 'JWT Token has expired'
      nil
    rescue JWT::DecodeError => e
      Rails.logger.info "JWT Decode Error: #{e.message}"
      nil
    end
  end
end