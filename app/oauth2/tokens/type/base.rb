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
        when :create.to_s
          errors = token_validate auth_params
        when :update.to_s
          errors = refresh_validate auth_params
        when :destroy.to_s
          errors = revoke_validate auth_params
        else
          raise StandardError 'Invalid action'
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
        raise NotImplementedError
      end

      def timedelta_from_now(to)
        to.tv_sec - Time.now.tv_sec
      end
    end
  end
end