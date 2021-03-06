class AuthorizationCode < ApplicationRecord
  has_and_belongs_to_many :access_tokens
  belongs_to :client
  #TODO: validate user input
  validates_length_of :redirect_url, in: 2..255

  # TODO: rename to active_token
  def token
    access_tokens.where(deleted: false, refresh: false).where(
      'access_tokens.expires > ?', Time.now).first
  end

  # TODO: rename to active_refresh_token
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

  def self.find_by_token(token)
    joins(:access_tokens).where(access_tokens: { token: token }).first
  end

  def expired?
    expires <= Time.now
  end

  def expire!
    self.update(expires: Time.now - 2.seconds)
  end

  def self.find_by_client_id(client_id)
    # TODO: order by time created
    joins(:client).where(clients: { uid: client_id }).where('expires > ?',
                                                            Time.now).first
  end
end
