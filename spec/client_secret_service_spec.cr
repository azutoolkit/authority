require "./spec_helper"

describe Authority::ClientSecretService do
  describe ".hash" do
    it "returns a bcrypt hash" do
      hash = Authority::ClientSecretService.hash("my-secret")
      hash.should start_with "$2a$"
    end

    it "generates different hashes for same input (salt)" do
      hash1 = Authority::ClientSecretService.hash("secret")
      hash2 = Authority::ClientSecretService.hash("secret")
      hash1.should_not eq hash2
    end

    it "generates hashes of consistent length" do
      hash = Authority::ClientSecretService.hash("test-secret")
      hash.size.should eq 60 # Standard bcrypt hash length
    end
  end

  describe ".verify" do
    it "returns true for correct secret" do
      hash = Authority::ClientSecretService.hash("my-secret")
      Authority::ClientSecretService.verify("my-secret", hash).should be_true
    end

    it "returns false for incorrect secret" do
      hash = Authority::ClientSecretService.hash("my-secret")
      Authority::ClientSecretService.verify("wrong-secret", hash).should be_false
    end

    it "returns false for empty secret" do
      hash = Authority::ClientSecretService.hash("my-secret")
      Authority::ClientSecretService.verify("", hash).should be_false
    end

    it "returns false for nil-like empty hash" do
      Authority::ClientSecretService.verify("secret", "").should be_false
    end

    it "handles unicode secrets" do
      hash = Authority::ClientSecretService.hash("秘密パスワード")
      Authority::ClientSecretService.verify("秘密パスワード", hash).should be_true
      Authority::ClientSecretService.verify("wrong", hash).should be_false
    end
  end

  describe ".generate" do
    it "generates a random secret of specified length" do
      secret = Authority::ClientSecretService.generate(32)
      # Base64 encoded 32 bytes = ~43 characters
      secret.size.should be >= 32
    end

    it "generates unique secrets" do
      secrets = (1..100).map { Authority::ClientSecretService.generate(32) }
      secrets.uniq.size.should eq 100
    end

    it "generates URL-safe secrets" do
      secret = Authority::ClientSecretService.generate(32)
      secret.should_not match(/[+\/=]/)
    end
  end
end
