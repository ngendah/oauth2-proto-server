class TokensController < ApplicationController

  def update
    serve_request __method__
  rescue HttpError => error
    render_err error
  end

  def destroy
    serve_request __method__
  rescue HttpError => error
    render_err error
  end

  def show
    serve_request __method__
  rescue HttpError => error
    render_err error
  end

  protected

  def serve_request(method)
    auth_params = AuthParams.new(params, request.headers)
    server = request_servers method
    grant = server[:grant].call auth_params
    raise HttpError.new(server[:error][:title], server[:error][:message], server[:error][:status]) if grant.nil?

    errors = grant.access_token.is_valid auth_params
    unless errors.empty?
      raise HttpError.new(titles(:access_token_error),
                          errors.to_s, :bad_request)
    end
    render json: server[:process].call(grant, auth_params), status: :ok
  end

  def request_servers(method)
    {
      update: {
        grant: ->(auth_params) { Grants::Grant.from_token auth_params.refresh_token },
        error: { title: titles(:access_token_error),
                 message: user_err(:refresh_invalid_token),
                 status: :bad_request },
        process: ->(grant, auth_params) { grant.access_token.refresh(auth_params) }
      },
      destroy: {
        grant: ->(auth_params) { Grants::Grant.from_token auth_params.access_token },
        error: { title: titles(:access_token_error),
                 message: user_err(:token_invalid),
                 status: :bad_request },
        process: ->(grant, auth_params) { grant.access_token.revoke(auth_params) }
      },
      show: {
        grant: ->(auth_params) { Grants::Grant[auth_params.grant_type] },
        error: { title: titles(:access_token_error),
                 message: user_err(:grant_type_invalid),
                 status: :bad_request },
        process: ->(grant, auth_params) { grant.access_token.token(auth_params) }
      }
    }[method]
  end
end
