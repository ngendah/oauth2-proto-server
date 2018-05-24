class ChecksController < ApplicationController

  def show
    auth_params = AuthParams.new(params, request.headers)
    grant = Grants::Grant.from_token params[:token]
    if grant.nil?
      raise HttpError.new(titles(:access_token_error),
                          user_err(:token_invalid),
                          :not_found)
    end
    render json: grant.access_token.check(auth_params), status: :found
  rescue HttpError => error
    render_err error
  end
end