module Tokens
  module Type
    class Introspect < Base

      def type_name
        Introspect.type_name
      end

      def self.type_name
        :introspect.to_s
      end

      def query(auth_params)
        introspection = super auth_params
        if introspection[:active]
          if introspection[:grant_type] == :authorization_code.to_s ||
             introspection[:grant_type] == :implicit.to_s
            auth_code = ::AuthorizationCode.find_by_token auth_params.access_token
            introspection[:client_id] = auth_code.client.uid
          elsif introspection[:grant_type] == :user_credentials.to_s
            user = ::User.find_by_token auth_params.access_token
            introspection[:user_uid] = user.uid
          end
        end
        introspection
      end
  end
  end
end
