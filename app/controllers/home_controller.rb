class HomeController < ApplicationController
  def index
    render json: YAML.load_file("#{Rails.root}/docs/openapi/#{params[:doc]}.yml")
  rescue
    render json: YAML.load_file("#{Rails.root}/docs/openapi/default.yml")
  end
end
