require "flux"
require "uri"

class SessionFlux < Flux
  def initialize
    super()
  end

  def show
    step do
      visit "http://localhost:4000/signin"

      {
        username: field("#username", :css),
        password: field("#password", :css),
        submit:   field("#signin", :css),
      }
    end
  end

  def create(username : String, password : String)
    step do
      visit "http://localhost:4000/signin"

      sleep 3.seconds

      fill "#username", username, by: :css
      fill "#password", password, by: :css
      submit "#signin"

      sleep 3.seconds

      URI.parse(current_url).query_params
    end
  end
end
