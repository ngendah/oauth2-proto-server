require 'base64'
require 'digest'


module Tokens

  module Type

    # concrete class that implements all oauth2 authorization code, token request flow
    #
    class AuthorizationCode < Base

      # service token request
      #
      def token(auth_params, options = {})
        authorization_code = auth_params.authorization_code
        token = access_token authorization_code, options
        if auth_params.refresh_required
          unless options.key?(:correlation_uid)
            access_token = ::AccessToken.find_by_token token[:access_token]
            options[:correlation_uid] = access_token.correlation_uid
          end
          ref_token = refresh_token authorization_code, options
          token[:refresh_token] = ref_token[:access_token]
        end
        token
      end

      def type_name
        :authorization_code.to_s
      end

      def refresh(auth_params, options = {})
        refresh_token = auth_params.refresh_token
        auth_code = ::AuthorizationCode.find_by_token refresh_token
        access_token = ::AccessToken.find_by_token refresh_token
        auth_params.authorization_code = auth_code.code
        options[:correlation_uid] = access_token.correlation_uid
        token auth_params, options
      end

      protected

      def access_token(authorization_code, options = {})
        auth_code = ::AuthorizationCode.find_by_code authorization_code
        auth_code.delete_expired_tokens
        token = auth_code.token
        if token.nil? || token.expired?
          token = TokenGenerator.token
          correlation_uid = options.fetch :correlation_uid, SecureRandom.uuid
          auth_code.access_tokens << ::AccessToken.create(
            token: token[:access_token], expires: token[:expires_in],
            correlation_uid: correlation_uid, grant_type: type_name)
        else
          token = {access_token: token.token, expires_in: token.expires}
        end
        token[:scope] = []
        token_time_to_timedelta token
      end

      def refresh_token(authorization_code, options = {})
        auth_code = ::AuthorizationCode.find_by_code authorization_code
        refresh_token = auth_code.refresh_token
        unless refresh_token.nil? || refresh_token.invalid?
          refresh_token.revoke
        end
        expires_in = options.fetch :expires_in, 20.minutes
        correlation_uid = options.fetch :correlation_uid, nil
        refresh_token = TokenGenerator.token :default, {timedelta: expires_in}
        auth_code.access_tokens << ::AccessToken.create(
          token: refresh_token[:access_token], refresh: true,
          expires: refresh_token[:expires_in], grant_type: type_name,
          correlation_uid: correlation_uid
        )
        token_time_to_timedelta refresh_token
      end

      def refresh_validate(auth_params)
        errors = []
        refresh_token = auth_params.refresh_token
        unless ::AccessToken.valid?(refresh_token, true)
          errors.append(user_err(:refresh_invalid_token))
        end
        errors
      end

      def token_validate(auth_params)
        errors = []
        code = ::AuthorizationCode.find_by_code auth_params.authorization_code
        errors.concat code_validate(code)
        errors.concat client_validate(code, auth_params) unless code.nil?
        errors
      end

      def code_validate(code)
        errors = []
        errors.append(user_err(:auth_code_invalid)) if code.nil?
        errors.append(user_err(:auth_code_expired)) if !code.nil? && code.expired?
        errors
      end

      def client_validate(code, auth_params)
        errors = []
        begin
          client_id = auth_params.client_id
          secret = auth_params.secret
          client = code.client
          is_valid = (client.uid == client_id && client.secret == secret)
          unless is_valid
            errors.append user_err(:auth_code_invalid_client_or_secret)
          end
          errors.concat(pkce_validate(code, auth_params)) if client.pkce
        rescue StandardError => error
          errors.append user_err(:auth_code_invalid_client_or_secret)
        end
        errors
      end

      def pkce_validate(code, auth_params)
        errors = []
        code_challenge = code.code_challenge
        calculated_code_challenge = generate_code_challenge(
          code.code_challenge_method, auth_params.code_verifier)
        is_invalid = code_challenge != calculated_code_challenge
        errors.append user_err(:auth_code_invalid_grant_error) if is_invalid
        errors
      end

      def generate_code_challenge(code_challenge_method, code_verifier)
        return code_verifier if code_challenge_method == 'PLAIN'
        digest = Digest::SHA256.hexdigest code_verifier
        Base64.urlsafe_encode64 digest
      end

    end
  end
end
