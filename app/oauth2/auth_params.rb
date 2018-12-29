require 'locale'
require 'cgi'


class AuthParams
  include Locale

  def initialize(params, headers)
    @params = params
    @headers = headers
  end

  def authorization_code
    @params[:code]
  end

  def authorization_code=(auth_code)
    @params[:code] = auth_code
  end

  def action
    @params[:action]
  end

  def endpoint
    {
      token: 'access_tokens',
      authorize: 'authorize'
    }[@params[:controller]]
  end

  def grant_type
    @params[:grant_type]
  end

  def response_type
    map_grant_type @params[:response_type]
  end

  def client_id
    @headers['Authorization'].nil? ? @params[:client_id] : client_secret[:client_id]
  end

  def secret
    Base64.decode64 client_secret[:secret]
  end

  def user_uid_password
    [@params[:user_uid], @params[:password]]
  end

  def user_uid=(user_uid)
    @params[:user_uid] = user_uid
  end

  def password=(password)
    @params[:password] = password
  end

  def refresh_token
    @params[:refresh_token]
  end

  def refresh_required
    @params[:refresh]
  end

  def redirect_url
    redirect_url = @params[:redirect_url]
    redirect_url = CGI.unescape(redirect_url) unless redirect_url.nil?
    redirect_url
  end

  def redirect?
    !@params[:redirect]
  end

  def refresh_token_key_exists?
    @params.key?(:refresh_token)
  end

  def bearer_token
    finder = /(Bearer +)(.+)/
    bearer = finder.match(@headers['Authorization'])
    if bearer.length < 3
      raise StandardError, internal_err(:bad_auth_header)
    end
    unless bearer[1].strip == 'Bearer'
      raise StandardError, internal_err(:bad_auth_method_expect_bearer)
    end
    bearer[2]
  end

  def access_token
    @params[:token]
  end

  def code_challenge
    @params[:code_challenge]
  end

  def code_challenge_method
    @params[:code_challenge_method]
  end

  def code_verifier
    @params[:code_verifier]
  end

  def state
    @params[:state]
  end

  protected

  def client_secret
    finder = /([Bb]earer +)?([\w-]+):(.+)/
    client_and_secret = finder.match(@headers['Authorization'])
    if client_and_secret.length < 4
      raise StandardError, internal_err(:bad_auth_header)
    end
    { client_id: client_and_secret[2], secret: client_and_secret[3] }
  end

  def map_grant_type(grant)
    { 'code' => 'authorization_code' }.fetch(grant, grant)
  end
end
