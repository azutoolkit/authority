def process_user_info_request(state, user, password)
  auth_url = OAUTH_CLIENT.get_authorize_uri(scope: "read,openid", state: state)
  code, _expected_state, cookie_headers = AuthorizationCodeFlux.flow(
    auth_url, user.username, password)

  cookie_headers.add("Content-Type", "application/json")
  cookie_headers.add("Accept", "application/json")
  token = OAUTH_CLIENT.get_access_token_using_authorization_code(code)
  client = OAUTH_CLIENT.http_client
  token.authenticate(client)

  client.get(Authority::Owner::UserInfoEndpoint.path, headers: cookie_headers)
end
