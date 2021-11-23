require "./spec_helper"

describe Authority do
  http_client = OAUTH_CLIENT.http_client

  describe "Device Code Flow" do
    it "gets device code" do
      password = Faker::Internet.password
      owner = create_owner(password: password)
      username = owner.username
      response = http_client.post("/device/code?client_id=#{CLIENT_ID}&scope=read")

      response.status_code.should eq 201
      json = JSON.parse(response.body)

      json["verification_uri"].should eq "http://localhost:4000/activate"

      verification_url = json["verification_full"].as_s
      user_code = json["user_code"].as_s
      device_code = json["device_code"].as_s

      url = DeviceCodeFlux.flow(verification_url, username, password, user_code, "allowed")

      url.should eq "http://localhost:4000/activate"

      response = http_client.post("/device/token", form: {
        "grant_type" => "urn:ietf:params:oauth:grant-type:device_code",
        "code"       => device_code,
        "client_id"  => CLIENT_ID,

      })

      access_token = JSON.parse(response.body)

      access_token["access_token"].as_s.should_not be_empty
      access_token["token_type"].as_s.should eq "Bearer"
      access_token["refresh_token"].as_s.should_not be_empty
      access_token["access_token"].as_s.should_not be_empty
    end

    it "gets device token" do
    end
  end
end
