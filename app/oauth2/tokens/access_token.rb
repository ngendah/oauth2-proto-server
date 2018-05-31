module Tokens
  class AccessToken
    def self.[](key)
      {
        'authorization_code' => Type::AuthorizationCode,
        'user_credentials' => Type::UserCredentials,
        'implicit' => Type::Implicit,
        'introspect' => Type::Introspect
      }[key].new
    end
  end
end
