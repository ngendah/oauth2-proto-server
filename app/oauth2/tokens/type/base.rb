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
        raise NotImplementedError
      end

      def refresh(auth_params, options = {})
        raise NotImplementedError
      end

      def type_name
        raise NotImplementedError
      end

      protected

      def token_time_to_timedelta(token)
        token[:expires_in] = timedelta_from_now token[:expires_in]
        token
      end

      def timedelta_from_now(to)
        to.tv_sec - Time.now.tv_sec
      end
    end
  end
end