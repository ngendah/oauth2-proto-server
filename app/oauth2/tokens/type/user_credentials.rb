module Tokens
  module Type
    class UserCredentials < Base

      def is_valid(auth_params)
        errors = []
        client = ::Client.find_by_uid auth_params.client_id
        if !client.nil?
          user_id, password = auth_params.username_password
          user = client.find_user_by_uid user_id
          if user.nil? || !user.authenticate(password)
            errors.append(
              user_err(:user_credentials_invalid_username_or_password))
          end
        elsif auth_params.refresh_token_key_exists?
          refresh_token = auth_params.refresh_token
          if ::AccessToken.valid?(refresh_token, true)
            token = ::AccessToken.find_by_token refresh_token
            if token.expired?
              errors.append(user_err(:refresh_token_expired))
            end
          else
            errors.append(user_err(:refresh_invalid_token))
          end
        else
          errors.append(user_err(:user_credentials_invalid_client_id))
        end
        errors
      end

      def token(auth_params, options = {})
        user_id, = auth_params.username_password
        token = access_token user_id, options
        if options.fetch(:refresh_required, true)
          ref_token = refresh_token user_id, options
          token[:refresh_token] = ref_token[:access_token]
        end
        token
      end

      def type_name
        :user_credentials.to_s
      end

      def refresh(auth_params, options = {})
        user = ::User.find_by_token auth_params.refresh_token
        auth_params.params[:username] = user.uid
        auth_params.params[:password] = ''
        token auth_params, options
      end

      protected

      def access_token(user_uid, options = {})
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

      def refresh_token(user_id, options = {})
        user = ::User.find_by_uid user_id
        refresh_token = user.refresh_token
        if refresh_token.nil? || refresh_token.expired?
          expires_in = options.fetch(:expires_in, 20.minutes)
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
