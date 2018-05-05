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

  def type_name
    'authorization_code_grant_type'
  end

  def valid_client?(request)
    params = request.params
    if params.key?(:client_id)
      @errors.concat validate_client(params)
    else
      @errors.append(t_err(:auth_code_client_required))
    end
    @errors.empty?
  end

  def valid_code?(request)
    params = request.params
    if params.key?(:authorization_code)
      @errors.concat validate_code(params, request.headers['Authorization'])
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
      redirect_url = client.redirect_url if redirect_url.nil?
      token = TokenGenerator.token :default, { length: 16 }
      auth_code = AuthorizationCode.create(
        code: token[:access_token], client: client,
        redirect_url: redirect_url, expires: token[:expires_in])
    end
    redirect_url = auth_code.client.redirect_url if redirect_url.nil?
    raise StandardError('redirect url not specified') if redirect_url.nil?
    "#{redirect_url}?code=#{auth_code.code}"
  end

  def token(authorization_code, refresh_required)
    token = access_token authorization_code
    if refresh_required
      ref_token = refresh_token authorization_code
      token[:refresh_token] = ref_token[:access_token]
    end
    token
  end

  protected

  def access_token(authorization_code)
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
    token[:scope] = []
    token
  end

  def refresh_token(authorization_code, expires_in = 20.minutes)
    auth_code = AuthorizationCode.find_by_code authorization_code
    refresh_token = auth_code.refresh_token
    if refresh_token.nil? || refresh_token.expired?
      refresh_token = TokenGenerator.token :default, { timedelta: expires_in }
      auth_code.access_tokens << AccessToken.create(
        token: refresh_token[:access_token],
        refresh: true,
        expires: refresh_token[:expires_in])
    else
      refresh_token = { access_token: refresh_token.token,
                        expires_in: refresh_token.expires }
    end
    refresh_token
  end

  def validate_client(params)
     # TODO: check if client can has been allowed to use this grant type
    errors = []
    client = Client.find_by_uid params[:client_id]
    errors.append(t_err(:auth_code_invalid_client)) if client.nil?
    redirect_url = params[:redirect_url]
    redirect_url = client.redirect_url if redirect_url.nil?
    if redirect_url.nil? || !valid_uri?(redirect_url)
      errors.append(t_err(:auth_code_redirect_url_required))
    end
    errors
  end

  def validate_code(params, authorization)
    errors = []
    errors.append(
      t_err(:auth_code_invalid_client_or_secret)
    ) if authorization.nil? || authorization.split(':').length == 1
    code = AuthorizationCode.find_by_code params[:code]
    if !code.nil?
      errors.append(t_err(:auth_code_expired)) if code.expired?
      uid, secret = authorization.split(':')
      client = code.client
      is_valid = (client.uid == uid && client.secret == secret)
      errors.append(
        t_err(:auth_code_invalid_client_or_secret)) unless is_valid
    else
      errors.append(t_err(:auth_code_invalid))
    end
    errors
  end

  def valid_uri?(url)
    uri = URI.parse(url)
    uri.host && uri.scheme
  rescue URI::InvalidURIError
  false
  end
end
