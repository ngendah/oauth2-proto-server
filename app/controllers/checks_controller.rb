class ChecksController < ApplicationController

  def show
    auth_params = AuthParams.new(params, request.headers)
    grant = Grants::Grant.from_token auth_params.bearer_token
    if grant.nil?
      raise HttpError.new(titles(:access_token_error),
                          user_err(:token_invalid),
                          :not_found)
    end
    render json: grant.introspect.query(auth_params), status: :ok
  rescue HttpError => error
    render json: { active: false }, status: :ok
  end
end