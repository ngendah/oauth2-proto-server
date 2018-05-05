require 'authorization_code_grant_type'
require 'response'


class TokenController < ApplicationController

  def index
    case params[:grant_type]
    when 'authorization_code'
      auth_code = AuthorizationCodeGrantType.new
      raise HttpError.new(auth_code.err_title, auth_code.errors.to_s,
                          :bad_request) unless auth_code.valid_code?(request)
      render json: AccessTokenResponse.new(request, auth_code), status: :ok
    else
      raise HttpError.new('GET', 'Invalid grant type', :bad_request)
    end
  rescue HttpError => error
    render_err error
  end
end
