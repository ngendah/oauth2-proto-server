class ErrorsController < ApplicationController
  def routing
    render :json => { message: 'Bad request' }, :status => 404
  end
end
