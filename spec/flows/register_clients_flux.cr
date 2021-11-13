require "flux"
require "uri"

class RegisterClientFlux < Flux
  def self.flow(url)
    new(url).call
  end

  def initialize(@url : String)
    options = Marionette.firefox_options(args: ["-headless"])
    super(Marionette::Browser::Firefox, options)
  end

  def call
    step do
      visit @url

      fill "[name=name]", Faker::Company.first_name, by: :css
      fill "[name=redirect_uri]", Faker::Internet.url("example.com", "/callback"), by: :css
      fill "[name=logo]", Faker::Company.logo, by: :css
      fill "[name=description]", Faker::Lorem.paragraph(2), by: :css

      sleep 1.seconds

      submit "[type=submit]", by: :css

      sleep 2.seconds

      current_url
    end
  end
end
