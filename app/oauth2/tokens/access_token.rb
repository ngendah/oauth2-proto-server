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
end