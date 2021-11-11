require "./spec_helper"

describe "Register Owner Flow" do
  it "creates a new owner" do
    url = RegisterOwnerFlux.flow("http://localhost:4000/register")

    Authority::OwnerEntity.query.count.should eq 1
    url.should eq "http://localhost:4000/signin"
  end
end
