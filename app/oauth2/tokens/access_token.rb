module Tokens
  class AccessToken
    def self.[](key)
      {
        Type::AuthorizationCode.type_name => Type::AuthorizationCode,
        Type::UserCredentials.type_name => Type::UserCredentials,
        Type::Implicit.type_name => Type::Implicit,
        Type::Introspect.type_name => Type::Introspect
      }[key].new
    end
  end
end
