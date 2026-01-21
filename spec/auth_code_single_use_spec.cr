require "./spec_helper"

describe Authority::AuthCodeSingleUseService do
  # Clear used codes before each test
  Spec.before_each do
    AuthorityDB.exec("DELETE FROM oauth_used_auth_codes")
  end

  describe ".mark_used" do
    it "marks an authorization code as used" do
      code = "test-code-#{UUID.random}"
      Authority::AuthCodeSingleUseService.mark_used(code, CLIENT_ID).should be_true
    end

    it "can mark same code twice without error" do
      code = "test-code-#{UUID.random}"
      Authority::AuthCodeSingleUseService.mark_used(code, CLIENT_ID).should be_true
      Authority::AuthCodeSingleUseService.mark_used(code, CLIENT_ID).should be_true
    end
  end

  describe ".used?" do
    it "returns false for unused code" do
      code = "unused-code-#{UUID.random}"
      Authority::AuthCodeSingleUseService.used?(code).should be_false
    end

    it "returns true for used code" do
      code = "test-code-#{UUID.random}"
      Authority::AuthCodeSingleUseService.mark_used(code, CLIENT_ID)
      Authority::AuthCodeSingleUseService.used?(code).should be_true
    end
  end

  describe ".try_use" do
    it "returns true and marks code for first use" do
      code = "test-code-#{UUID.random}"
      result = Authority::AuthCodeSingleUseService.try_use(code, CLIENT_ID)
      result[:success].should be_true
      result[:reuse_detected].should be_false
      Authority::AuthCodeSingleUseService.used?(code).should be_true
    end

    it "returns false and sets reuse_detected for second use" do
      code = "test-code-#{UUID.random}"
      Authority::AuthCodeSingleUseService.try_use(code, CLIENT_ID)

      result = Authority::AuthCodeSingleUseService.try_use(code, CLIENT_ID)
      result[:success].should be_false
      result[:reuse_detected].should be_true
    end

    it "detects reuse from different clients" do
      code = "test-code-#{UUID.random}"
      Authority::AuthCodeSingleUseService.try_use(code, CLIENT_ID)

      result = Authority::AuthCodeSingleUseService.try_use(code, "different-client")
      result[:success].should be_false
      result[:reuse_detected].should be_true
    end
  end

  describe ".cleanup_expired" do
    it "removes codes older than the specified age" do
      code = "old-code-#{UUID.random}"
      Authority::AuthCodeSingleUseService.mark_used(code, CLIENT_ID)

      # This shouldn't actually clean up right away in production,
      # but we can test the method exists and runs
      Authority::AuthCodeSingleUseService.cleanup_expired(0.seconds)

      # With 0 seconds, the code we just added should be cleaned up
      Authority::AuthCodeSingleUseService.used?(code).should be_false
    end
  end
end
