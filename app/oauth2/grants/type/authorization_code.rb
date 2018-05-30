module Grants
  module Type
    class AuthorizationCode
      attr_reader :access_token
      attr_reader :authorize
      attr_reader :introspect

      def initialize(access_tokens, authorize)
        @access_token = access_tokens[
          self.class.name.underscore.split('/').last]
        @authorize = authorize
        @introspect = access_tokens[:introspect.to_s]
      end
    end
  end
end