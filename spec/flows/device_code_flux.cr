require "flux"
require "uri"

class DeviceCodeFlux < Flux
  def self.flow(url, username, password, user_code, verification)
    new(url, username, password, user_code, verification).call
  end

  def initialize(
    @url : String,
    @username : String,
    @password : String,
    @user_code : String,
    @verification : String
  )
    options = Marionette.firefox_options(args: ["-headless"])
    super(Marionette::Browser::Firefox, options)
  end

  def call
    step do
      visit @url

      fill "#username", @username, by: :css
      fill "#password", @password, by: :css
      submit "#signin", by: :css

      sleep 1.seconds

      submit "[value=#{@verification}]", by: :css

      sleep 1.seconds

      return current_url
    end
  end
end
