require "../spec_helper"

describe Authority::IPAllowlistService do
  Spec.before_each do
    Authority::IPAllowlistService.clear_cache
    ENV.delete("ADMIN_ALLOWED_IPS")
  end

  Spec.after_each do
    Authority::IPAllowlistService.clear_cache
    ENV.delete("ADMIN_ALLOWED_IPS")
  end

  describe ".allowed?" do
    context "when not configured" do
      it "allows any IP when env var is not set" do
        Authority::IPAllowlistService.allowed?("192.168.1.1").should be_true
        Authority::IPAllowlistService.allowed?("10.0.0.1").should be_true
      end

      it "allows any IP when env var is empty" do
        ENV["ADMIN_ALLOWED_IPS"] = ""
        Authority::IPAllowlistService.allowed?("192.168.1.1").should be_true
      end
    end

    context "with single IP" do
      it "allows matching IP" do
        ENV["ADMIN_ALLOWED_IPS"] = "192.168.1.100"
        Authority::IPAllowlistService.allowed?("192.168.1.100").should be_true
      end

      it "denies non-matching IP" do
        ENV["ADMIN_ALLOWED_IPS"] = "192.168.1.100"
        Authority::IPAllowlistService.allowed?("192.168.1.101").should be_false
      end
    end

    context "with multiple IPs" do
      it "allows any matching IP (comma-separated)" do
        ENV["ADMIN_ALLOWED_IPS"] = "192.168.1.100,10.0.0.5,172.16.0.1"
        Authority::IPAllowlistService.allowed?("192.168.1.100").should be_true
        Authority::IPAllowlistService.allowed?("10.0.0.5").should be_true
        Authority::IPAllowlistService.allowed?("172.16.0.1").should be_true
      end

      it "allows any matching IP (space-separated)" do
        ENV["ADMIN_ALLOWED_IPS"] = "192.168.1.100 10.0.0.5"
        Authority::IPAllowlistService.allowed?("10.0.0.5").should be_true
      end

      it "denies non-matching IP" do
        ENV["ADMIN_ALLOWED_IPS"] = "192.168.1.100,10.0.0.5"
        Authority::IPAllowlistService.allowed?("192.168.1.101").should be_false
      end
    end

    context "with CIDR ranges" do
      it "allows IP within CIDR range" do
        ENV["ADMIN_ALLOWED_IPS"] = "192.168.1.0/24"
        Authority::IPAllowlistService.allowed?("192.168.1.1").should be_true
        Authority::IPAllowlistService.allowed?("192.168.1.100").should be_true
        Authority::IPAllowlistService.allowed?("192.168.1.255").should be_true
      end

      it "denies IP outside CIDR range" do
        ENV["ADMIN_ALLOWED_IPS"] = "192.168.1.0/24"
        Authority::IPAllowlistService.allowed?("192.168.2.1").should be_false
        Authority::IPAllowlistService.allowed?("10.0.0.1").should be_false
      end

      it "handles /32 CIDR (single host)" do
        ENV["ADMIN_ALLOWED_IPS"] = "192.168.1.100/32"
        Authority::IPAllowlistService.allowed?("192.168.1.100").should be_true
        Authority::IPAllowlistService.allowed?("192.168.1.101").should be_false
      end

      it "handles /16 CIDR" do
        ENV["ADMIN_ALLOWED_IPS"] = "10.0.0.0/16"
        Authority::IPAllowlistService.allowed?("10.0.0.1").should be_true
        Authority::IPAllowlistService.allowed?("10.0.255.255").should be_true
        Authority::IPAllowlistService.allowed?("10.1.0.1").should be_false
      end
    end

    context "with mixed IPs and CIDRs" do
      it "allows matching IP or CIDR" do
        ENV["ADMIN_ALLOWED_IPS"] = "192.168.1.0/24,10.0.0.5"
        Authority::IPAllowlistService.allowed?("192.168.1.50").should be_true
        Authority::IPAllowlistService.allowed?("10.0.0.5").should be_true
        Authority::IPAllowlistService.allowed?("10.0.0.6").should be_false
      end
    end

    context "with IPv6-mapped IPv4" do
      it "handles ::ffff: prefix" do
        ENV["ADMIN_ALLOWED_IPS"] = "192.168.1.100"
        Authority::IPAllowlistService.allowed?("::ffff:192.168.1.100").should be_true
      end
    end

    context "with invalid input" do
      it "denies invalid IP format" do
        ENV["ADMIN_ALLOWED_IPS"] = "192.168.1.100"
        Authority::IPAllowlistService.allowed?("invalid").should be_false
        Authority::IPAllowlistService.allowed?("").should be_false
      end
    end
  end

  describe ".configured?" do
    it "returns false when env var not set" do
      Authority::IPAllowlistService.configured?.should be_false
    end

    it "returns false when env var is empty" do
      ENV["ADMIN_ALLOWED_IPS"] = ""
      Authority::IPAllowlistService.configured?.should be_false
    end

    it "returns true when env var is set" do
      ENV["ADMIN_ALLOWED_IPS"] = "192.168.1.0/24"
      Authority::IPAllowlistService.configured?.should be_true
    end
  end
end
