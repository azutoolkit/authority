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

    all_cookies.as_a.each do |c|
      cookies << HTTP::Cookie.new(
        name: c["name"].as_s,
        value: c["value"].as_s,
        path: c["path"].as_s,
        expires: c["expiry"].as_i64.minutes.from_now,
        domain: c["domain"].as_s,
        secure: c["secure"].as_bool,
        http_only: c["secure"].as_bool,
        samesite: HTTP::Cookie::SameSite.parse(c["sameSite"].as_s)
      )
    end

    cookies.add_request_headers(headers)
  end
end
