module Tokens
  class RevokeToken
    def [](token)
      access_token = ::AccessToken.find_by_token token
      Tokens::AccessToken.new[access_token.grant_type]
    end
  end
end