require "./spec_helper"

describe Authority::ScopeValidationService do
  # Use the global test client from spec_helper (has "read" scope)
  describe ".validate" do
    it "returns valid for single scope that is allowed" do
      result = Authority::ScopeValidationService.validate(CLIENT_ID, "read")
      result.valid?.should be_true
      result.scopes.should eq "read"
    end

    it "returns invalid for scope not in client's allowed list" do
      result = Authority::ScopeValidationService.validate(CLIENT_ID, "admin")
      result.valid?.should be_false
      result.error.should eq "invalid_scope"
      result.error_description.should_not be_nil
      if desc = result.error_description
        desc.should contain "admin"
      end
    end

    it "returns invalid when any requested scope is not allowed" do
      result = Authority::ScopeValidationService.validate(CLIENT_ID, "read admin")
      result.valid?.should be_false
      result.error.should eq "invalid_scope"
    end

    it "handles comma-separated scopes" do
      result = Authority::ScopeValidationService.validate(CLIENT_ID, "read")
      result.valid?.should be_true
    end

    it "handles empty requested scopes" do
      result = Authority::ScopeValidationService.validate(CLIENT_ID, "")
      result.valid?.should be_true
    end

    it "is case-sensitive for scopes" do
      result = Authority::ScopeValidationService.validate(CLIENT_ID, "READ")
      result.valid?.should be_false
    end

    it "returns invalid_client for unknown client" do
      result = Authority::ScopeValidationService.validate("unknown-client-id", "read")
      result.valid?.should be_false
      result.error.should eq "invalid_client"
    end
  end
end
