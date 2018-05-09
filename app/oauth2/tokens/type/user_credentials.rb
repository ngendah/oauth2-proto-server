module Tokens
  module Type
    class UserCredentials < Base

      def is_valid(auth_params)
        errors = []
        client = ::Client.find_by_uid auth_params.client_id
        if !client.nil?
          user = client.user
          username, password = auth_params.username_and_password
          if user.uid != username || !user.authenticate(password)
            errors.append(
              user_err(:user_credentials_invalid_username_or_password))
          end
        elsif auth_params.refresh_token_key_exists?
          refresh_token = auth_params.refresh_token
          unless ::AccessToken.valid?(refresh_token, true)
            errors.append(user_err(:refresh_invalid_token))
          end
        else
          errors.append(user_err(:user_credentials_invalid_client_id))
        end
        errors
      end

      def token(auth_params, options = {})
        username, = auth_params.username_and_password
        token = access_token username
        if options.fetch(:refresh_required, true)
          ref_token = refresh_token username
          token[:refresh_token] = ref_token[:access_token]
        end
        token
      end

      def type_name
        :user_credentials.to_s
      end

      def refresh(auth_params, options = {})
        user = ::User.find_by_token auth_params.refresh_token
        auth_params.headers['Authorization'] = "#{user.uid}:"
        token auth_params, options
      end

      protected

      def access_token(user_uid)
        user = ::User.find_by_uid user_uid
        user.delete_expired_tokens
        token = user.token
        if token.nil? || token.expired?
          token = TokenGenerator.token
          user.access_tokens << ::AccessToken.create(
            token: token[:access_token], expires: token[:expires_in],
            grant_type: type_name)
        else
          token = { access_token: token.token, expires_in: token.expires }
        end
        token[:scope] = []
        token_time_to_timedelta token
      end

      def refresh_token(user_id, expires_in = 20.minutes)
        user = ::User.find_by_uid user_id
        refresh_token = user.refresh_token
        if refresh_token.nil? || refresh_token.expired?
          refresh_token = TokenGenerator.token :default, timedelta: expires_in
          user.access_tokens << ::AccessToken.create(
            token: refresh_token[:access_token], refresh: true,
            expires: refresh_token[:expires_in], grant_type: type_name)
        else
          refresh_token = { access_token: refresh_token.token,
                            expires_in: refresh_token.expires }
        end
        token_time_to_timedelta refresh_token
      end
    end
  end
end