require 'i18n'

module Locale
  def user_err(key)
    I18n.t(key, scope: [:errors])
  end

  def internal_err(key)
    I18n.t(key, scope: [:errors, :internal])
  end

  def titles(key)
    I18n.t(key, scope: [:titles])
  end
end