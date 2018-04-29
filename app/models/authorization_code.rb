class AuthorizationCode < ApplicationRecord
  belongs_to :client
  has_and_belongs_to_many :access_tokens

  scope :token, ->(refresh) { where(
          { access_tokens: {
              deleted: false, expires < Time.now, refresh: refresh}})
        }

  def token
    joins(:access_tokens).token(false).first
  end

  def refresh_token
     joins(:access_tokens).token(true).first
  end

  def self.delete_expired_tokens
    joins(:access_tokens).where(
      {access_tokens: {deleted: false, expires >= Time.now}}).update_all(
        deleted: true)
  end

  def expired?
    self.expires >= Time.now
  end

  def self.find_by_client_id(client_id)
    where({client: {uid: client_id}}).where(expires < Time.now)
  end

end
