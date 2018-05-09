

module Tokens

  class AccessToken
    def initialize
      @tokens = {
        'authorization_code' => Type::AuthorizationCode.new,
        'user_credentials' => Type::UserCredentials.new
      }
    end

    def [](key)
      @tokens[key]
    end
  end

  class RefreshToken
    def [](refresh_token)
      access_token = ::AccessToken.find_by_token refresh_token
      AccessToken.new[access_token.grant_type]
    end
  end
end