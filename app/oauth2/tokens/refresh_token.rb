module Tokens
  class RefreshToken
    def [](refresh_token)
      access_token = ::AccessToken.find_by_token refresh_token
      Tokens::AccessToken.new[access_token.grant_type]
    end
  end
end