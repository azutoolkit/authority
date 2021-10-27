require "flux"
require "uri"

class AuthorizationCode < Flux
  def self.flow(url, username, password)
    new(url, username, password).call
  end

  def initialize(@url : String, @username : String, @password : String)
    super()
  end

  def call
    redirect = step do |page|
      page.visit @url
      page.implicit_wait 5.seconds
      page.fill "#username", @username
      page.fill "#password", @password
      page.submit "#signin"

      page.implicit_wait 2.seconds
      page.submit "#approve"
      page.implicit_wait 2.seconds

      URI.parse(page.current_url).query_params
    end

    {redirect["code"].to_s, redirect["state"].to_s}
  end
end
