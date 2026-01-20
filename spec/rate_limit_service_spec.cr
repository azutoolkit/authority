require "./spec_helper"

describe Authority::RateLimitService do
  # Clear rate limit state before each test
  Spec.before_each do
    Authority::RateLimitService.clear_all
  end

  describe ".allowed?" do
    it "allows requests within limit" do
      key = "test:#{UUID.random}"
      5.times { Authority::RateLimitService.allowed?(key, :signin).should be_true }
    end

    it "blocks requests exceeding limit" do
      key = "test:#{UUID.random}"
      # Signin has a limit of 5 per minute
      5.times { Authority::RateLimitService.allowed?(key, :signin) }
      Authority::RateLimitService.allowed?(key, :signin).should be_false
    end

    it "tracks different keys separately" do
      key1 = "test:#{UUID.random}"
      key2 = "test:#{UUID.random}"

      5.times { Authority::RateLimitService.allowed?(key1, :signin) }
      Authority::RateLimitService.allowed?(key1, :signin).should be_false

      # key2 should still have its full quota
      Authority::RateLimitService.allowed?(key2, :signin).should be_true
    end

    it "tracks different operations separately" do
      key = "test:#{UUID.random}"

      5.times { Authority::RateLimitService.allowed?(key, :signin) }
      Authority::RateLimitService.allowed?(key, :signin).should be_false

      # Same key, different operation should have its own quota
      Authority::RateLimitService.allowed?(key, :token).should be_true
    end
  end

  describe ".remaining" do
    it "returns full limit for new key" do
      key = "test:#{UUID.random}"
      Authority::RateLimitService.remaining(key, :signin).should eq 5
    end

    it "decrements remaining after each request" do
      key = "test:#{UUID.random}"
      Authority::RateLimitService.allowed?(key, :signin)
      Authority::RateLimitService.remaining(key, :signin).should eq 4
    end

    it "returns 0 when limit exceeded" do
      key = "test:#{UUID.random}"
      6.times { Authority::RateLimitService.allowed?(key, :signin) }
      Authority::RateLimitService.remaining(key, :signin).should eq 0
    end
  end

  describe ".retry_after" do
    it "returns nil when not rate limited" do
      key = "test:#{UUID.random}"
      Authority::RateLimitService.retry_after(key, :signin).should be_nil
    end

    it "returns seconds until window resets when rate limited" do
      key = "test:#{UUID.random}"
      6.times { Authority::RateLimitService.allowed?(key, :signin) }
      retry_after = Authority::RateLimitService.retry_after(key, :signin)
      retry_after.should_not be_nil
      if seconds = retry_after
        seconds.should be > 0
        seconds.should be <= 60 # Signin window is 60 seconds
      end
    end
  end

  describe "operation limits" do
    it "uses correct limit for signin (5 per minute)" do
      key = "test:#{UUID.random}"
      5.times { Authority::RateLimitService.allowed?(key, :signin).should be_true }
      Authority::RateLimitService.allowed?(key, :signin).should be_false
    end

    it "uses correct limit for token (20 per minute)" do
      key = "test:#{UUID.random}"
      20.times { Authority::RateLimitService.allowed?(key, :token).should be_true }
      Authority::RateLimitService.allowed?(key, :token).should be_false
    end

    it "uses correct limit for authorize (30 per minute)" do
      key = "test:#{UUID.random}"
      30.times { Authority::RateLimitService.allowed?(key, :authorize).should be_true }
      Authority::RateLimitService.allowed?(key, :authorize).should be_false
    end
  end
end
