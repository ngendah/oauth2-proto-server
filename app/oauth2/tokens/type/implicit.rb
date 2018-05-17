module Tokens
  module Type

    class Implicit < AuthorizationCode
      include Lib::AuthorizationCode

      def token(auth_params, options = {})
        auth_code = generate_code auth_params, options
        auth_params.authorization_code = auth_code[:code]
        token = super auth_params, options
        result = "#{auth_code[:redirect_url]}#access_token=#{token[:access_token]}&expires_in=#{token[:expires_in]}"
        if auth_params.refresh_required
          result += "&refresh_token=#{token[:refresh_token]}"
        end
        result
      end

      def type_name
        :implicit.to_s
      end

      protected

      def token_validate(auth_params)
        validate_client auth_params
      end
    end
  end
end