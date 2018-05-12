class TokenController < ApplicationController

  def create
    auth_params = AuthParams.new(params, request.headers)
    grant = Grants::Grant.from_refresh_token params[:refresh_token]
    if grant.nil?
      raise HttpError.new(titles(:access_token_error),
                          user_err(:refresh_invalid_token), :bad_request)
    end
    errors = grant.access_token.is_valid(auth_params)
    unless errors.empty?
      raise HttpError.new(titles(:access_token_error),
                          errors.to_s, :bad_request)
    end
    render json: grant.access_token.refresh(auth_params), status: :ok
  rescue HttpError => error
    render_err error
  end

  def revoke
    auth_params = AuthParams.new(params, request.headers)
    access_token = Tokens::RevokeToken.new[params[:token]]
    if access_token.nil?
      raise HttpError.new(titles(:access_token_error),
                          user_err(:access_token_invalid_token),
                          :bad_request)
    end
    # TODO: add validation
    render json: access_token.revoke(auth_params), status: :ok
  rescue HttpError => error
    render_err error
  end

  def index
    auth_params = AuthParams.new(params, request.headers)
    grant = Grants::Grant.new[params[:grant_type]]
    if grant.nil?
      raise HttpError.new(titles(:access_token_error),
                          user_err(:grant_type_invalid), :bad_request)
    end
    errors = grant.access_token.is_valid(auth_params)
    unless errors.empty?
      raise HttpError.new(titles(:access_token_error),
                          errors.to_s, :bad_request)
    end
    render json: grant.access_token.token(auth_params), status: :ok
  rescue HttpError => error
    render_err error
  end
end
