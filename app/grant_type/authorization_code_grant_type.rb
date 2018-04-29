require 'grant_type'
require 'token_generator'
require 'uri'


class AuthorizationCodeGrantType < GrantType
  attr_reader :errors
  attr_reader :err_title

  def initialize
    @err_title = t_title(:auth_code_error)
    @errors = []
  end

  def grant_type_name
    'authorization_code_grant_type'
  end

  def valid_client?(request)
    params = request.params
    if params.key?(:client_id)
      @errors.append validate_client(params)
    else
      @errors.append(t_err(:auth_code_client_required))
    end
    @errors.empty?
  end

  def valid_code?(request)
    params = request.params
    if params.key?(:code)
      @errors.append validate_code(params, request.headers['Authorization'])
    else
      @errors.append(t_err(:auth_code_required))
    end
    @errors.empty?
  end

  def authorize(client_id, redirect_url)
    auth_code = AuthorizationCode.find_by_client_id client_id
    if auth_code.nil?
      client = Client.find_by_uid client_id
      redirect_url = URI.decode(redirect_url)
      token = TokenGenerator.token opts: { length: 16 }
      auth_code = AuthorizationCode.create(
        code: token[:access_token], client: client,
        redirect_url: redirect_url, expires: token[:expires_in])
    end
    "#{auth_code.redirect_url}?code=#{auth_code.code}"
  end

  def access_token(authorization_code, refresh_required = false)
    auth_code = AuthorizationCode.find_by_code authorization_code
    auth_code.delete_expired_tokens
    token = auth_code.token
    if token.nil? || token.expired?
      token = TokenGenerator.token
      auth_code.access_tokens << AccessToken.create(
        token: token[:access_token], expires: token[:expires_in])
    else
      token = { access_token: token.token, expires_in: token.expires }
    end
    if refresh_required
      refresh_token = auth_code.refresh_token
      if refresh_token.nil? || refresh_token.expired?
        refresh_token = TokenGenerator.token
        auth_code.access_tokens << AccessToken.create(
          token: refresh_token[:access_token],
          refresh: true,
          expires: refresh_token[:expires])
        token[:refresh_token] = refresh_token[:acess_token]
      else
        token[:refresh_token] = refresh_token.token
      end
    end
    token
  end

  protected

  def validate_client(params)
    errors = []
    client = Client.find_by_uid params[:client_id]
    errors.append(t_err(:auth_code_invalide_client)) if client.nil?
    redirect_url = params[:redirect_url]
    # TODO: check if client can has been allowed to use this grant type
    errors.append(
      t_err(:auth_code_redirect_url_required)) if redirect_url.nil?
    errors
  end

  def validate_code(params, authorization)
    errors = []
    errors.append(
      t_err(:auth_code_authorization_required)
    ) if authorization.nil? || authorization.split.empty?
    code = AuthorizationCode.find_by_code params[:code]
    if !code.nil?
      errors.append(t_err(:auth_code_expired)) if code.expired?
      client_secret = authorization.split(':')
      client = code.client
      is_valid = (client.uid != client_secret[0] ||
        client.secret != client_secret[1])
      errors.append(
        t_err(:auth_code_invalid_client_or_secret)) unless is_valid
    else
      errors.append(t_err(:auth_code_invalid))
    end
    errors
  end
end
