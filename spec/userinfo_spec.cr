require "./spec_helper"

describe Authority do
  describe "UserInfo Endpoint" do
    it "gets user claims" do
      password = Faker::Internet.password
      state = Random::Secure.hex
      user = create_owner(password: password)

      response = process_user_info_request state, user, password
      payload = JSON.parse(response.body)
      payload["sub"].should eq user.id.to_s
      payload["email"].should eq user.email
    end
  end
end
