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
            grant: lambda {|a_p| Grants::Grant.from_token a_p.refresh_token},
            error: {title: titles(:access_token_error),
                    message: user_err(:refresh_invalid_token),
                    status: :bad_request},
            process: lambda {|g, a_p| g.access_token.refresh(a_p)}
        },
        destroy: {
            grant: lambda {|a_p| Grants::Grant.from_token a_p.access_token},
            error: {title: titles(:access_token_error),
                    message: user_err(:token_invalid),
                    status: :bad_request},
            process: lambda {|g, a_p| g.access_token.revoke(a_p)}
        },
        show: {
            grant: lambda {|a_p| Grants::Grant[a_p.grant_type]},
            error: {title: titles(:access_token_error),
                    message: user_err(:grant_type_invalid),
                    status: :bad_request},
            process: lambda {|g, a_p| g.access_token.token(a_p)}
        }
    }[method]
  end
end
