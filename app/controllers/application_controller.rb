require 'http_errors'
require 'locale'

class ApplicationController < ActionController::API
  include Locale

  protected

  def render_err(http_err)
    _render_err http_err.title, http_err.message,
                http_err.status, http_err.link
  end

  private

  def _render_err(title, message, status, link = '')
    render json: {description: message, title: title, link: link}, status: status
  end
end
