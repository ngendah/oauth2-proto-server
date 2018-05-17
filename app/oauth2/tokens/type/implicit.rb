module Tokens
  module Type
    class Implicit < AuthorizationCode
      included Lib::AuthorizationCode

      def token(auth_params, options = {})
        auth_code = generate_code(auth_params, options)
        auth_params.authorization_code = auth_code[:code]
        token = super.token auth_params, options
        token_type = options.fetch(:token_type, 'Bearer')
        "#{auth_code[:redirect_url]}#access_token=#{token[:access_token]}&token_type=#{token_type}&expires_in=#{token[:expires_in]}"
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