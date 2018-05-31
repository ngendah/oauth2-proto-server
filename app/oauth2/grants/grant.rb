module Grants

  class Grant
    def self.[](key)
      access_tokens = Tokens::AccessToken
      {
        'authorization_code' => Type::AuthorizationCode.new(
          access_tokens, Authorities::Authorize.new
        ),
        'user_credentials' => Type::UserCredentials.new(access_tokens),
        'implicit' => Type::Implicit.new(access_tokens)
      }[key]
    end

    def self.from_token(token)
      access_token = ::AccessToken.find_by_token token
      self[access_token.nil? ? '' : access_token.grant_type]
    end
  end
end
