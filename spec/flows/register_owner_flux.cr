require "flux"
require "uri"

class RegisterOwnerFlux < Flux
  def self.flow(url)
    new(url).call
  end

  def initialize(@url : String)
    options = Marionette.firefox_options(args: ["-headless"])
    super(Marionette::Browser::Firefox, options)
  end

  def call
    password = Faker::Internet.password
    email = Faker::Internet.email

    step do
      visit @url

      fill "[name=first_name]", Faker::Name.first_name, by: :css
      fill "[name=last_name]", Faker::Name.last_name, by: :css
      fill "[name=email]", email, by: :css
      fill "[name=username]", email, by: :css
      fill "[name=password]", password, by: :css
      fill "[name=confirm_password]", password, by: :css

      checkbox "terms"

      sleep 1.seconds

      submit "[type=submit]", by: :css

      sleep 2.seconds

      current_url
    end
  end
end
