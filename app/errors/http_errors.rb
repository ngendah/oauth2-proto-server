class HttpError < StandardError
  attr_reader :status
  attr_reader :link
  attr_reader :title

  def initialize(title, message, status, link = '')
    super(message)
    @status = status
    @link = link
    @title = title
  end
end
