# frozen_string_literal: true

class Swagger::Docs::Config
  def self.base_api_controller
    ActionController::API
  end

  def self.transform_path(path, api_version)
    path
  end
end

Swagger::Docs::Config.register_apis(
  '2.0' => {
    api_extension_type: :json,
    api_file_path: 'public/',
    clean_directory: true
  }
)
