class AuthorizationCode < WithAccessTokens
  belongs_to :client
  #TODO: validate user input
  validates_length_of :redirect_url, in: 2..255

  def expired?
    expires <= Time.now
  end

  def self.find_by_client_id(client_id)
    # TODO: order by time created
    joins(:client).where(clients: { uid: client_id }).where('expires > ?',
                                                            Time.now).first
  end
end
