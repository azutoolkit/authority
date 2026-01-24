require "flux"
require "uri"

class AuthorizationCodeFlux < Flux
  def self.flow(url, username, password)
    new(url, username, password).call
  end

  def initialize(@url : String, @username : String, @password : String)
    options = Marionette.firefox_options(args: [""])
    super(Marionette::Browser::Firefox, options)
  end

  def call
    redirect, all_cookies = step do
      visit @url

      sleep 1.seconds

      fill "#username", @username, by: :css
      fill "#password", @password, by: :css
      submit "#signin", by: :css
      session_cookies = execute("GetAllCookies")

      sleep 1.seconds
      submit "#approve", by: :css
      sleep 2.seconds
      {URI.parse(current_url).query_params, session_cookies}
    end

    {redirect["code"].to_s, redirect["state"].to_s, parse_cookies(all_cookies)}
  end

  def parse_cookies(all_cookies)
    cookies = HTTP::Cookies.new
    headers = HTTP::Headers.new

    all_cookies.as_a.each do |cookie|
      cookies << HTTP::Cookie.new(
        name: cookie["name"].as_s,
        value: cookie["value"].as_s,
        path: cookie["path"].as_s,
        expires: cookie["expiry"].as_i64.minutes.from_now,
        domain: cookie["domain"].as_s,
        secure: cookie["secure"].as_bool,
        http_only: cookie["secure"].as_bool,
        samesite: HTTP::Cookie::SameSite.parse(cookie["sameSite"].as_s)
      )
    end

    cookies.add_request_headers(headers)
  end
end
