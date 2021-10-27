require "azu"
require "clear"
require "authly"

# Docs - https://azutopia.gitbook.io/azu/defining-your-app
module Authority
  include Azu
  configure do |c|
    # Default HTML templates path
    c.templates.path = "public/templates"

    # Uncomment to enable Spark real time apps
    # Docs: https://azutopia.gitbook.io/azu/spark-1
    # c.router.ws "/live-view", Spark

    # To Server static content
    c.router.get "/*", Handler::Static.new
  end
end

require "./config/**"
require "./services/**"
require "./requests/**"
require "./responses/**"
require "./models/**"
require "./endpoints/**"
require "./config/**"
