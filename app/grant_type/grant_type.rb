
class GrantType


  def valid?(request)
    raise NotImplementedError
  end

  def authorize(opts={})
    raise NotImplementedError
  end

  def token(opts={})
     raise NotImplementedError
  end

  def type_name
    raise NotImplementedError
  end

  protected

  def t_err(key)
    I18n.t(key, scope: [:errors])
  end

  def t_title(key)
    I18n.t(key, scope: [:titles, :grant_types])
  end

end
