class AuthorizesController < ApplicationController

  def show
    auth_params = AuthParams.new(params, request.headers)
    grant = Grants::Grant.new[params[:grant_type]]
    if grant.nil?
      raise HttpError.new(titles(:auth_code_error),
                          user_err(:grant_type_invalid), :bad_request)
    end
    errors = grant.authorize.is_valid(auth_params)
    unless errors.empty?
      raise HttpError.new(titles(:auth_code_error), errors.to_s, :bad_request)
    end
    render json: {}, status: :temporary_redirect,
           location: grant.authorize.code(auth_params)
  rescue HttpError => error
    render_err error
  end
end
