module Grants
  module Type
    class UserCredentials
      attr_reader :access_token

      def initialize(access_tokens)
        @access_token = access_tokens[
          self.class.name.underscore.split('/').last]
      end
    end
  end
end