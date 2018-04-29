
class GrantType


  def valid?(request)
    raise NotImplementedError
  end

  def authorize(opts={})
    raise NotImplementedError
  end

  def access_token(opts={})
    raise NotImplementedError
  end

  def refresh_token(opts={})
    raise NotImplementedError
  end

  def grant_type_name
    raise NotImplementedError
  end

  protected

  def t_err(key)
    I18n.t(key, scopes: [:errors])
  end

  def t_title(key)
    I18n.t(key, scopes: [:titles, :grant_types])
  end

end
