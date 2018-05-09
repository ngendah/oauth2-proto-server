module Grants

  class Grant
    def initialize
      access_tokens = Tokens::AccessToken.new
      @grants = {
        'authorization_code' => Type::AuthorizationCode.new(
          access_tokens, Authorities::Authorize.new
        ),
        'user_credentials' => Type::UserCredentials.new(access_tokens),
        'client_credentials' => Type::ClientCredentials.new
      }
    end

    def [](key)
      @grants[key]
    end
  end
end