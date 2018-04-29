require 'bcrypt'

TYPE_DEFAULT = 'default'
TYPE_JWT = 'jwt'

class TokenGenerator 

  def self.token(type=TYPE_DEFAULT, opts={})
    case type
    when TYPE_DEFAULT
      default_token_generator opts
    when TYPE_JWT
      jwt_generator opts
    else
      raise StandardError, 'Invalid token generation strategy'
    end
  end

  private

  def self.default_token_generator(opts)
    {
      access_token: SecureRandom.base64(opts.fetch(:length, 100)),
      expires: Time.now + opts.fetch(:timedelta, 10.minutes)
    }
  end

  def self.jwt_generator(opts)
    raise StandardError, 'Not implemented'
  end

end
