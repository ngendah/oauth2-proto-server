module Grants
  module Type
    class AuthorizationCode
      attr_reader :access_token
      attr_reader :authorize

      def initialize(access_tokens, authorize)
        @access_token = access_tokens[
          self.class.name.underscore.split('/').last]
        @authorize = authorize
      end
    end
  end
end