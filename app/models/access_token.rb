class AccessToken < ApplicationRecord
  validates_presence_of :grant_type

  def expired?
    expires < Time.now
  end

  def self.valid?(token, is_refresh = false)
    where(token: token, refresh: is_refresh, deleted: false).count.positive?
  end

  def self.revoke(token)
    token = where(token: token)
    where(correlation_uid: token.correlation_uid).update_all(
      deleted: true, revoked_at: Time.now
    )
  end
end
