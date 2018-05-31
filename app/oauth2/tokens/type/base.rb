require 'locale'
require 'token_generator'


module Tokens
  module Type
    class Base
      include Locale

      def token(auth_params, options = {})
        raise NotImplementedError
      end

      def is_valid(auth_params)
        case auth_params.action
        when :show.to_s
          errors = token_validate auth_params
        when :update.to_s
          errors = refresh_validate auth_params
        when :destroy.to_s
          errors = revoke_validate auth_params
        else
          raise StandardError, 'Invalid action'
        end
        errors
      end

      def refresh(auth_params, options = {})
        raise NotImplementedError
      end

      def revoke(auth_params, options = {})
        ::AccessToken.revoke auth_params.access_token
      end

      def type_name
        raise NotImplementedError
      end

      def query(auth_params)
        access_token = ::AccessToken.find_by_token auth_params.access_token
        introspection = { active: false }
        unless access_token.nil? || access_token.expired?
          introspection = {
            expires_in: access_token.expires,
            active: !access_token.expired?,
            grant_type: access_token.grant_type,
            scope: access_token.scopes,
            token_type: access_token.refresh ? 'refresh' : 'access'
          }
          introspection = token_time_to_timedelta introspection
        end
        introspection
      end

      protected

      def token_time_to_timedelta(token)
        token[:expires_in] = timedelta_from_now token[:expires_in]
        token
      end

      def token_validate(auth_params)
        raise NotImplementedError
      end

      def refresh_validate(auth_params)
        raise NotImplementedError
      end

      def revoke_validate(auth_params)
        errors = []
        begin
          bearer_token = ::AccessToken.find_by_token auth_params.bearer_token
          if bearer_token.nil? || bearer_token.expired?
            errors.append user_err(:bearer_token_invalid)
          elsif bearer_token.refresh
            errors.append user_err(:bearer_token_is_refresh)
          end
          token = ::AccessToken.find_by_token auth_params.access_token
          errors.append(user_err(:token_invalid)) if token.nil?
        rescue StandardError => error
          errors.append user_err(:bad_auth_header)
        end
        errors
      end

      def timedelta_from_now(to)
        to.tv_sec - Time.now.tv_sec
      end
    end
  end
end
