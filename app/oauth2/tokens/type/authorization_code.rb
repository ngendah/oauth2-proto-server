module Tokens

  module Type

    class AuthorizationCode < Base

      def is_valid(auth_params)
        errors = []
        begin
          code = ::AuthorizationCode.find_by_code auth_params.authorization_code
          if !code.nil?
            errors.append(user_err(:auth_code_expired)) if code.expired?
            client_id = auth_params.client_id
            secret = auth_params.secret
            client = code.client
            is_valid = (client.uid == client_id && client.secret == secret)
            unless is_valid
              errors.append(user_err(:auth_code_invalid_client_or_secret))
            end
          elsif auth_params.refresh_token_key_exists?
            refresh_token = auth_params.refresh_token
            unless ::AccessToken.valid?(refresh_token, true)
              errors.append(user_err(:refresh_invalid_token))
            end
          else
            errors.append(user_err(:auth_code_invalid))
          end
        rescue StandardError => error
          errors.append(user_err(:auth_code_invalid_client_or_secret))
        end
        errors
      end

      def token(auth_params, options = {})
        token = access_token auth_params.authorization_code
        if options.fetch(:refresh_required, true)
          ref_token = refresh_token auth_params.authorization_code
          token[:refresh_token] = ref_token[:access_token]
        end
        token
      end

      def type_name
        :authorization_code.to_s
      end

      def refresh(auth_params, options = {})
        auth_code = ::AuthorizationCode.find_by_token auth_params.refresh_token
        auth_params.params[:authorization_code] = auth_code.code
        token auth_params, options
      end

      protected

      def access_token(authorization_code)
        auth_code = ::AuthorizationCode.find_by_code authorization_code
        auth_code.delete_expired_tokens
        token = auth_code.token
        if token.nil? || token.expired?
          token = TokenGenerator.token
          auth_code.access_tokens << ::AccessToken.create(
            token: token[:access_token], expires: token[:expires_in],
            grant_type: type_name)
        else
          token = {access_token: token.token, expires_in: token.expires}
        end
        token[:scope] = []
        token_time_to_timedelta token
      end

      def refresh_token(authorization_code, expires_in = 20.minutes)
        auth_code = ::AuthorizationCode.find_by_code authorization_code
        refresh_token = auth_code.refresh_token
        if refresh_token.nil? || refresh_token.expired?
          refresh_token = TokenGenerator.token :default, {timedelta: expires_in}
          auth_code.access_tokens << ::AccessToken.create(
            token: refresh_token[:access_token], refresh: true,
            expires: refresh_token[:expires_in], grant_type: type_name)
        else
          refresh_token = {access_token: refresh_token.token,
                           expires_in: refresh_token.expires}
        end
        token_time_to_timedelta refresh_token
      end
    end
  end
end