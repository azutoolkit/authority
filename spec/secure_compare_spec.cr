require "./spec_helper"

describe Authority::SecureCompare do
  describe ".secure_compare" do
    it "returns true for equal strings" do
      Authority::SecureCompare.secure_compare("secret", "secret").should be_true
    end

    it "returns false for different strings of same length" do
      Authority::SecureCompare.secure_compare("secret", "secreT").should be_false
    end

    it "returns false for different length strings" do
      Authority::SecureCompare.secure_compare("short", "longer").should be_false
    end

    it "returns false for empty vs non-empty" do
      Authority::SecureCompare.secure_compare("", "secret").should be_false
    end

    it "handles empty strings" do
      Authority::SecureCompare.secure_compare("", "").should be_true
    end

    it "handles unicode strings" do
      Authority::SecureCompare.secure_compare("héllo", "héllo").should be_true
      Authority::SecureCompare.secure_compare("héllo", "hello").should be_false
    end

    it "handles special characters" do
      Authority::SecureCompare.secure_compare("p@ss!w0rd#$%", "p@ss!w0rd#$%").should be_true
      Authority::SecureCompare.secure_compare("p@ss!w0rd#$%", "p@ss!w0rd#$&").should be_false
    end

    it "handles long strings" do
      long_string = "a" * 10000
      Authority::SecureCompare.secure_compare(long_string, long_string).should be_true
      Authority::SecureCompare.secure_compare(long_string, long_string + "b").should be_false
    end
  end
end
