require 'authorization_code_grant_type'
require 'response'


class TokenController < ApplicationController

  def new
    refresh_token = params[:token_refresh]
    is_valid = !refresh_token.nil? || AccessToken.valid?(refresh_token, true)
    raise HttpError.new('POST',
        t_err(:refresh_invalid_token), :bad_request) unless is_valid
    case AccessToken.type(refresh_token)
    when AuthorizationCodeGrantType.name.underscore
      auth_code = AuthorizationCodeGrantType.new
      is_valid = auth_code.valid_refresh?(refresh_token)
      raise HttpError.new(auth_code.err_title, auth_code.errors.to_s,
                          :bad_request) unless is_valid
      render json: AccessTokenResponse.new(request, auth_code), status: :ok
    else
      raise HttpError.new('GET', t_err(:grant_type_invalid), :bad_request)
    end
  rescue HttpError => error
    render_err error
  end

  def index
    case params[:grant_type]
    when 'authorization_code'
      auth_code = AuthorizationCodeGrantType.new
      raise HttpError.new(auth_code.err_title, auth_code.errors.to_s,
                          :bad_request) unless auth_code.valid_code?(request)
      render json: AccessTokenResponse.new(request, auth_code), status: :ok
    else
      raise HttpError.new('GET', t_err(:grant_type_invalid), :bad_request)
    end
  rescue HttpError => error
    render_err error
  end
end
