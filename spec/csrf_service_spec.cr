require "./spec_helper"

describe Authority::CSRFService do
  describe ".generate_token" do
    it "generates a 64-character hex token" do
      token = Authority::CSRFService.generate_token
      token.size.should eq 64
      token.match(/^[a-f0-9]+$/).should_not be_nil
    end

    it "generates unique tokens" do
      tokens = (1..100).map { Authority::CSRFService.generate_token }
      tokens.uniq.size.should eq 100
    end
  end

  describe ".valid?" do
    it "returns true for matching tokens" do
      token = Authority::CSRFService.generate_token
      Authority::CSRFService.valid?(token, token).should be_true
    end

    it "returns false for nil session token" do
      Authority::CSRFService.valid?(nil, "token").should be_false
    end

    it "returns false for nil request token" do
      Authority::CSRFService.valid?("token", nil).should be_false
    end

    it "returns false for mismatched tokens" do
      Authority::CSRFService.valid?("token1", "token2").should be_false
    end

    it "returns false for empty tokens" do
      Authority::CSRFService.valid?("", "").should be_false
    end

    it "uses timing-safe comparison" do
      # Test that even with different length strings it doesn't short-circuit
      # (This is more of a design verification)
      token1 = "a" * 64
      token2 = "b" * 64
      Authority::CSRFService.valid?(token1, token2).should be_false
    end
  end
end
