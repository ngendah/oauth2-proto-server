require 'authorization_code_grant_type'
require 'response'

class AuthorizeController < ApplicationController

  def show
    case params[:response_type]
    when 'authorization_code'
      auth_code = AuthorizationCodeGrantType.new
      raise HttpError.new(auth_code.err_title, auth_code.errors.to_s,
                          :bad_request) unless auth_code.valid_client?(request)
      render text: AuthorizeResponse.new(request, auth_code), status: :ok
    else
      raise HttpError.new(
        'GET',
        'Invalid authorize response type', :bad_request)
    end
  rescue HttpError => error
    render_err error
  end
end
