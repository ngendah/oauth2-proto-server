class AuthorizesController < ApplicationController

  def show
    auth_params = AuthParams.new(params, request.headers)
    grant = Grants::Grant[auth_params.grant_type]
    if grant.nil?
      raise HttpError.new(titles(:auth_code_error),
                          user_err(:grant_type_invalid), :bad_request)
    end
    errors = grant.authorize.is_valid(auth_params)
    unless errors.empty?
      raise HttpError.new(titles(:auth_code_error), errors.to_s, :bad_request)
    end
    render json: {}, status: :found,
           location: grant.authorize.code(auth_params)
  rescue HttpError => error
    render_err error
  end

  # API documentation
  swagger_controller :authorize, 'Authorize grant type'
  swagger_api :show do
    summary 'Authorize a valid client request by issuing a code'
    notes <<-NOTES
      Authorizes a request with a valid client, which means a valid client id
    NOTES
    param :grant_type, 'Grant Type', :string, :required, 'Available options are: authorization_code'
    param :client_id, 'Client ID', :string, :required, 'Users client ID'
    param :redirect_url, 'Redirect URL', :string, :required, 'Redirect Url'
    response :found, nil, {}
    response :bad_request, 'The client was not found', Errors: []
  end
end
