require "./spec_helper"

describe Authority do
  describe "Show" do
    it "displays signin form" do
      session_flux = SessionFlux.new

      result = session_flux.show

      result[:username].should_not be_nil
      result[:password].should_not be_nil
      result[:submit].should_not be_nil
    end
  end

  describe "Create" do
    it "create a new session" do
      password = Faker::Internet.password
      session_flux = SessionFlux.new
      user = create_owner(password: password)
      result = session_flux.create user.username, password
      result.should be_a URI::Params
    end
  end
end
