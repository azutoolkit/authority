def prepare_code_challenge_url(username, password, method = "S256", scope = "read")
  state = Random::Secure.hex
  code_verifier = Faker::Internet.password(43, 128)

  code_challenge = case method
                   when "S256"  then Digest::SHA256.base64digest(code_verifier)
                   when "plain" then code_verifier
                   end

  auth_url = OAUTH_CLIENT.get_authorize_uri(scope: scope, state: state) do |param|
    param.add "code_challenge", code_challenge
    param.add "code_challenge_method", method
  end

  code, expected_state = AuthorizationCodeFlux.flow(auth_url, username, password)
  {code, code_verifier, expected_state}
end

def prepare_code_challenge_url_with_nonce(username, password, method = "S256", scope = "read", nonce = "")
  state = Random::Secure.hex
  code_verifier = Faker::Internet.password(43, 128)

  code_challenge = case method
                   when "S256"  then Digest::SHA256.base64digest(code_verifier)
                   when "plain" then code_verifier
                   end

  auth_url = OAUTH_CLIENT.get_authorize_uri(scope: scope, state: state) do |param|
    param.add "code_challenge", code_challenge
    param.add "code_challenge_method", method
    param.add "nonce", nonce unless nonce.empty?
  end

  code, expected_state = AuthorizationCodeFlux.flow(auth_url, username, password)
  {code, code_verifier, expected_state}
end

def create_token_request(code, code_verifier, scope = "")
  http_client = OAUTH_CLIENT.http_client
  headers = HTTP::Headers{
    "Accept"        => "application/json",
    "Content-Type"  => "application/x-www-form-urlencoded",
    "Authorization" => "Basic #{Base64.strict_encode("#{CLIENT_ID}:#{CLIENT_SECRET}")}",
  }

  http_client.post("/token", headers: headers, form: {
    "grant_type"    => "authorization_code",
    "redirect_uri"  => REDIRECT_URI,
    "code"          => code,
    "scope"         => scope,
    "code_verifier" => code_verifier,
  })
end
