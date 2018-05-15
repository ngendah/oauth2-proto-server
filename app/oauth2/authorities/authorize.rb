require 'token_generator'
require 'locale'
require 'cgi'


module Authorities

  class Authorize
    include Locale

    def is_valid(auth_params)
      errors = []
      client = ::Client.find_by_uid auth_params.client_id
      errors.append(user_err(:auth_code_invalid_client)) if client.nil?
      redirect_url = auth_params.redirect_url
      redirect_url = client.redirect_url if redirect_url.nil? && !client.nil?
      if redirect_url.nil? || !valid_url?(redirect_url)
        errors.append(user_err(:auth_code_redirect_url_required))
      end
      errors
    end

    def code(auth_params, options = {})
      auth_code = ::AuthorizationCode.find_by_client_id auth_params.client_id
      redirect_url = auth_params.redirect_url
      if auth_code.nil?
        client = ::Client.find_by_uid auth_params.client_id
        redirect_url = client.redirect_url if redirect_url.nil?
        token = TokenGenerator.token :default, { length: 16 }
        auth_code = ::AuthorizationCode.create(
          code: token[:access_token], client: client,
          redirect_url: redirect_url, expires: token[:expires_in])
      end
      redirect_url = auth_code.redirect_url if redirect_url.nil?
      "#{redirect_url}?code=#{auth_code.code}"
    end

    protected

    def valid_url?(url)
      uri = URI.parse(url)
      uri.host && uri.scheme
    rescue URI::InvalidURIError
      false
    end
  end
end