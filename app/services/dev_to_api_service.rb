class DevToApiService
  include HTTParty
  base_uri 'https://dev.to/api'

  def initialize(username)
    @username = username
  end

  def fetch_articles
    response = self.class.get("/articles", query: { username: @username })
    
    if response.success?
      response.parsed_response
    else
      Rails.logger.error "DevTo API Error: #{response.code} - #{response.message}"
      []
    end
  rescue StandardError => e
    Rails.logger.error "DevTo API Exception: #{e.message}"
    []
  end
end