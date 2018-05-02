class AuthorizationCode < ApplicationRecord
  belongs_to :client
  has_and_belongs_to_many :access_tokens

  def token
    access_tokens.where(deleted: false, refresh: false).where(
      'access_tokens.expires > ?', Time.now).first
  end

  def refresh_token
    access_tokens.where(deleted: false, refresh: true).where(
      'access_tokens.expires > ?', Time.now
    ).first
  end

  def delete_expired_tokens
    access_tokens.where(deleted: false).where(
      'access_tokens.expires <= ?', Time.now
    ).update_all(deleted: true)
  end

  def expired?
    expires >= Time.now
  end

  def self.find_by_client_id(client_id)
    joins(:client).where(clients: { uid: client_id }).where('expires > ?',
                                                            Time.now).first
  end

end
