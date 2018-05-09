class AccessToken < ApplicationRecord
  validates_presence_of :grant_type

  def expired?
    expires >= Time.now
  end

  def self.valid?(token, is_refresh=false)
    where(token: token, refresh: is_refresh, deleted: false).count > 0
  end
end
