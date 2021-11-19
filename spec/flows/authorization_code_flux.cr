require "flux"
require "uri"

class AuthorizationCodeFlux < Flux
  def self.flow(url, username, password)
    new(url, username, password).call
  end

  def initialize(@url : String, @username : String, @password : String)
    options = Marionette.firefox_options(args: ["-headless"])
    super(Marionette::Browser::Firefox, options)
  end

  def call
    redirect = step do
      visit @url

      sleep 1.seconds

      fill "#username", @username, by: :css
      fill "#password", @password, by: :css
      submit "#signin", by: :css

      sleep 1.seconds

      submit "#approve", by: :css

      URI.parse(current_url).query_params
    end

    {redirect["code"].to_s, redirect["state"].to_s}
  end
end
