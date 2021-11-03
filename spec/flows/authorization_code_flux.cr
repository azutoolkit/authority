require "flux"
require "uri"

class AuthorizationCodeFlux < Flux
  def self.flow(url, username, password)
    new(url, username, password).call
  end

  def initialize(@url : String, @username : String, @password : String)
    super()
  end

  def call
    redirect = step do
      visit @url

      fill "#username", @username, by: :css
      fill "#password", @password, by: :css
      submit "#signin"

      implicit_wait 5.seconds

      submit "#approve"

      implicit_wait 5.seconds

      URI.parse(current_url).query_params
    end

    {redirect["code"].to_s, redirect["state"].to_s}
  end
end