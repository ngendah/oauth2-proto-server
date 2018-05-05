require 'authorization_code_grant_type'
require 'response'

class AuthorizeController < ApplicationController

  def index
    case params[:response_type]
    when 'authorization_code'
      auth_code = AuthorizationCodeGrantType.new
      raise HttpError.new(auth_code.err_title, auth_code.errors.to_s,
                          :bad_request) unless auth_code.valid_client?(request)
      redirect_path =  AuthorizeResponse.new(request, auth_code).to_text
      render json: {}, status: :temporary_redirect, location: redirect_path
    else
      raise HttpError.new(
        'GET',
        'Invalid authorize response type', :bad_request)
    end
  rescue HttpError => error
    render_err error
  end
end
