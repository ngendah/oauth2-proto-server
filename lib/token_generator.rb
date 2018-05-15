require 'bcrypt'

class TokenGenerator 

  def self.token(type=:default, opts={})
    case type
    when :default
      default_token_generator opts
    when :jwt
      jwt_generator opts
    else
      raise StandardError, "Invalid token generation strategy #{type}"
    end
  end

  private

  def self.default_token_generator(opts)
    {
      access_token: SecureRandom.urlsafe_base64(opts.fetch(:length, 100)),
      expires_in: Time.now + opts.fetch(:timedelta, 10.minutes)
    }
  end

  def self.jwt_generator(opts)
    raise StandardError, 'Not implemented'
  end

end
