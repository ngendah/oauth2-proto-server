module Authorities
  class Authorize
    include Lib::AuthorizationCode

    def is_valid(auth_params)
      validate_client auth_params
    end

    def code(auth_params, options = {})
      auth_code = generate_code(auth_params, options)
      "#{auth_code[:redirect_url]}?code=#{auth_code[:code]}"
    end
  end
end