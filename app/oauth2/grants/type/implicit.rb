module Grants
  module Type
    class Implicit
      attr_reader :access_token
      attr_reader :introspect

      def initialize(access_tokens)
        @access_token = access_tokens[
          self.class.name.underscore.split('/').last]
        @introspect = access_tokens[:introspect.to_s]
      end
    end
  end
end