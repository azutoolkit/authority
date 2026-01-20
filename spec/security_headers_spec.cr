require "./spec_helper"

describe Authority do
  describe "Security Headers" do
    client = HTTP::Client.new("localhost", 4000)

    describe "GET /signin (HTML endpoint)" do
      it "returns X-Content-Type-Options header" do
        response = client.get("/signin")
        response.headers["X-Content-Type-Options"].should eq "nosniff"
      end

      it "returns X-Frame-Options header" do
        response = client.get("/signin")
        response.headers["X-Frame-Options"].should eq "DENY"
      end

      it "returns X-XSS-Protection header" do
        response = client.get("/signin")
        response.headers["X-XSS-Protection"].should eq "1; mode=block"
      end

      it "returns Referrer-Policy header" do
        response = client.get("/signin")
        response.headers["Referrer-Policy"].should eq "strict-origin-when-cross-origin"
      end

      it "returns Content-Security-Policy header" do
        response = client.get("/signin")
        response.headers["Content-Security-Policy"].should_not be_nil
        response.headers["Content-Security-Policy"].should contain "default-src"
        response.headers["Content-Security-Policy"].should contain "frame-ancestors 'none'"
      end

      it "returns Strict-Transport-Security header" do
        response = client.get("/signin")
        response.headers["Strict-Transport-Security"].should contain "max-age="
      end
    end

    describe "GET /activate (HTML endpoint)" do
      it "returns security headers" do
        response = client.get("/activate")
        response.headers["X-Content-Type-Options"].should eq "nosniff"
        response.headers["X-Frame-Options"].should eq "DENY"
      end
    end
  end
end
