require "./spec_helper"
require "oauth2"
require "http/client"
require "flux"
require "uri"

class AuthorizationFlux < Flux
  DRIVER = :edge

  def approve(url, username, password)
    step do
      visit url
      implicit_wait 5.seconds
      fill "#username", username
      fill "#password", password
      submit "#signin"

      sleep 2.seconds
      submit "#approve"
      sleep 2.seconds

      return URI.parse(current_url).query_params
    end
  end
end

describe Authority do
  client_id = Faker::Internet.user_name
  client_secret = Faker::Internet.password
  username = Faker::Internet.email
  password = Faker::Internet.password
  redirect_uri = "http://www.example.com/callback"

  Clear::SQL.truncate("clients", cascade: true)
  Clear::SQL.truncate("authorization_codes", cascade: true)
  Clear::SQL.truncate("users", cascade: true)

  create_client_credentials(client_id, client_secret, redirect_uri)
  create_owner(username, password)

  oauth2_client = OAuth2::Client.new(
    "localhost",
    client_id,
    client_secret,
    port: 4000,
    scheme: "http",
    redirect_uri: redirect_uri)

  it "gets access token using authorization code grant" do
    state = Random::Secure.hex
    auth_flux = AuthorizationFlux.new
    auth_url = oauth2_client.get_authorize_uri(scope: "read", state: state)
    redirect = auth_flux.approve(auth_url, username, password)
    auth_code = redirect["code"].to_s
    token = oauth2_client.get_access_token_using_authorization_code(auth_code)

    redirect["state"].should eq state
    token.should be_a OAuth2::AccessToken::Bearer
  end

  it "gets access token using client credentials grant" do
    response = oauth2_client.get_access_token_using_client_credentials scope: "read"
  end

  it "gets access token using password grant" do
    response = oauth2_client.get_access_token_using_resource_owner_credentials username: username, password: password, scope: "read"
  end

  it "gets access token using refresh token" do
    refresh = oauth2_client.get_access_token_using_client_credentials scope: "read"
    response = oauth2_client.get_access_token_using_refresh_token refresh.refresh_token, scope: "read"
  end
end
