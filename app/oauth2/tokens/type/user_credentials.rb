module Tokens

  module Type

    # concrete class that implements all oauth2 user credentials, token request flow
    #
    class UserCredentials < Base

      def token(auth_params, options = {})
        user_id, = auth_params.user_uid_password
        token = access_token user_id, options
        if auth_params.refresh_required
          unless options.key?(:correlation_uid)
            access_token = ::AccessToken.find_by_token token[:access_token]
            options[:correlation_uid] = access_token.correlation_uid
          end
          ref_token = refresh_token user_id, options
          token[:refresh_token] = ref_token[:access_token]
        end
        token
      end

      def type_name
        UserCredentials.type_name
      end

      def self.type_name
        :user_credentials.to_s
      end

      def refresh(auth_params, options = {})
        refresh_token = auth_params.refresh_token
        user = ::User.find_by_token refresh_token
        access_token = ::AccessToken.find_by_token refresh_token
        auth_params.user_uid = user.uid
        auth_params.password = ''
        options[:correlation_uid] = access_token.correlation_uid
        token auth_params, options
      end

      protected

      def access_token(user_uid, options = {})
        super ::User.find_by_uid(user_uid), options
      end

      def refresh_token(user_id, options = {})
        super ::User.find_by_uid(user_id), options
      end

      def token_validate(auth_params)
        errors = []
        client = ::Client.find_by_uid auth_params.client_id
        if client.nil?
          errors.append(user_err(:user_credentials_invalid_client_id))
        else
          user_id, password = auth_params.user_uid_password
          user = client.find_user_by_uid user_id
          if user.nil? || !user.authenticate(password)
            errors.append(
              user_err(:user_credentials_invalid_user_uid_or_password))
          end
        end
        errors
      end

      def refresh_validate(auth_params)
        errors = []
        refresh_token = auth_params.refresh_token
        if ::AccessToken.valid?(refresh_token, true)
          token = ::AccessToken.find_by_token refresh_token
          if token.expired?
            errors.append(user_err(:refresh_token_expired))
          end
        else
          errors.append(user_err(:refresh_invalid_token))
        end
        errors
      end
    end
  end
end
