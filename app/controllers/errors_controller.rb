class ErrorsController < ApplicationController
  def index
    render_err HttpError.new(titles(:api_error),
                             internal_err(:route_not_found), :bad_request)
  end
end
