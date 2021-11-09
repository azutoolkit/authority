require "./spec_helper"

describe "Register User Flow" do
  it "creates a new user" do
    url = RegisterOwnerFlux.flow("http://localhost:4000/register")

    Authority::User.query.count.should eq 1
    url.should eq "http://localhost:4000/signin"
  end
end
