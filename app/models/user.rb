class User < ApplicationRecord
  has_and_belongs_to_many :access_tokens
  has_secure_password

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

  def self.find_by_token(token)
    joins(:access_tokens).where(access_tokens: { token: token }).first
  end
end
