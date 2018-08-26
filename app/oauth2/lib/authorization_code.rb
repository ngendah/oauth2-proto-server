require 'locale'
require 'token_generator'


module Lib
  module AuthorizationCode
    include Locale

    def validate_client(auth_params)
      errors = []
      client = ::Client.find_by_uid auth_params.client_id
      errors.append(user_err(:auth_code_invalid_client)) if client.nil?
      redirect_url = auth_params.redirect_url
      redirect_url = client.redirect_url if redirect_url.nil? && !client.nil?
      if redirect_url.nil? || !valid_url?(redirect_url)
        errors.append(user_err(:auth_code_redirect_url_required))
      end
      errors.concat validate_pkce(client, auth_params)
    end

    def generate_code(auth_params, options = {})
      auth_code = ::AuthorizationCode.find_by_client_id auth_params.client_id
      redirect_url = auth_params.redirect_url
      auth_code = generate_auth_code(auth_params) if auth_code.nil?
      redirect_url = auth_code.redirect_url if redirect_url.nil?
      { code: auth_code.code, redirect_url: redirect_url }
    end

    def valid_url?(url)
      uri = URI.parse(url)
      uri.host && uri.scheme
    rescue URI::InvalidURIError
      false
    end

    protected

    def generate_auth_code(auth_params)
      client = ::Client.find_by_uid auth_params.client_id
      redirect_url = client.redirect_url if redirect_url.nil?
      token = TokenGenerator.token :default, { length: 16 }
      if client.pkce
        code_challenge = auth_params.code_challenge
        code_challenge_method = auth_params.code_challenge_method.upcase
      end
      ::AuthorizationCode.create code: token[:access_token], client: client,
                                 redirect_url: redirect_url,
                                 expires: token[:expires_in],
                                 code_challenge: code_challenge,
                                 code_challenge_method: code_challenge_method
    end

    def validate_pkce(client, auth_params)
      errors = []
      if !client.nil? and client.pkce
        if auth_params.code_challenge.nil?
          errors.append(user_err(:auth_code_challenge_required))
        end
        if auth_params.code_challenge_method.nil?
          errors.append(user_err(:auth_code_challenge_method_required))
        end
        if !auth_params.code_challenge_method.nil? and (
          auth_params.code_challenge_method.upcase != "SHA256" ||
              auth_params.code_challenge_method.upcase != "PLAIN")
          errors.append user_err(:auth_code_invalid_code_challenge_method)
        end
      end
      errors
    end
  end
end
