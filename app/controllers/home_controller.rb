class HomeController < ApplicationController
  def index
    render json: YAML.load_file("#{Rails.root}/docs/openapi/api-doc.yml")
  end
end
