require 'token_generator.rb'
require 'uri'


class Response

  def initialize(request, grant_type)
    self.request = request
    self.grant_type = grant_type
  end

  def to_json
    raise NotImplementedError
  end

  def to_text
    raise NotImplementedError
  end
end


class AuthorizeResponse < Response

  def initialize(request, grant_type)
    super(request, grant_type)
  end

  def to_text
    params = request.params
    grant_type.authorize params[:client_id], params[:redirect_url]
  end
end


class AccessTokenResponse < Response

  def initialize(request, grant_type)
    super(request, grant_type)
  end

  def to_json
    params = request.params
    grant_type.access_token(params[:code], true).to_json
  end
end
