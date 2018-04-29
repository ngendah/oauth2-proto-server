class AccessToken < ApplicationRecord

  def expired?
    self.expires >= Time.now
  end
end
