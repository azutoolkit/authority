require "./spec_helper"

describe Authority::JWKSService do
  describe ".jwks" do
    context "with HS256 (symmetric) algorithm" do
      it "returns empty keys array" do
        # Default configuration uses HS256
        keys = Authority::JWKSService.jwks
        keys.should be_empty
      end
    end

    context "with RS256 (asymmetric) algorithm" do
      it "returns RSA public key components" do
        # Generate a test RSA key pair
        rsa = OpenSSL::PKey::RSA.new(2048)
        public_pem = String.build { |io| rsa.public_key.to_pem(io) }

        # Temporarily configure RS256
        original_algorithm = Authly.config.algorithm
        original_public_key = Authly.config.public_key

        begin
          Authly.config.algorithm = JWT::Algorithm::RS256
          Authly.config.public_key = public_pem

          keys = Authority::JWKSService.jwks
          keys.size.should eq 1

          jwk = keys.first
          jwk.kty.should eq "RSA"
          jwk.use.should eq "sig"
          jwk.alg.should eq "RS256"
          jwk.kid.should_not be_nil
          jwk.n.should_not be_nil
          jwk.e.should_not be_nil

          # Verify n and e are base64url encoded
          jwk.n.try(&.should_not(contain("+")))
          jwk.n.try(&.should_not(contain("/")))
          jwk.e.try(&.should_not(contain("+")))
          jwk.e.try(&.should_not(contain("/")))
        ensure
          Authly.config.algorithm = original_algorithm
          Authly.config.public_key = original_public_key
        end
      end

      it "generates consistent key ID (kid)" do
        rsa = OpenSSL::PKey::RSA.new(2048)
        public_pem = String.build { |io| rsa.public_key.to_pem(io) }

        original_algorithm = Authly.config.algorithm
        original_public_key = Authly.config.public_key

        begin
          Authly.config.algorithm = JWT::Algorithm::RS256
          Authly.config.public_key = public_pem

          keys1 = Authority::JWKSService.jwks
          keys2 = Authority::JWKSService.jwks

          keys1.first.kid.should eq keys2.first.kid
        ensure
          Authly.config.algorithm = original_algorithm
          Authly.config.public_key = original_public_key
        end
      end
    end

    context "with ES256 (ECDSA) algorithm" do
      it "returns EC public key components" do
        # Generate a test EC key pair
        ec = OpenSSL::PKey::EC.generate("P-256")
        public_pem = String.build { |io| ec.public_key.to_pem(io) }

        original_algorithm = Authly.config.algorithm
        original_public_key = Authly.config.public_key

        begin
          Authly.config.algorithm = JWT::Algorithm::ES256
          Authly.config.public_key = public_pem

          keys = Authority::JWKSService.jwks
          keys.size.should eq 1

          jwk = keys.first
          jwk.kty.should eq "EC"
          jwk.use.should eq "sig"
          jwk.alg.should eq "ES256"
          jwk.crv.should eq "P-256"
          jwk.kid.should_not be_nil
          jwk.x.should_not be_nil
          jwk.y.should_not be_nil

          # Verify x and y are base64url encoded (32 bytes for P-256)
          # Base64URL of 32 bytes = 43 characters (without padding)
          jwk.x.try(&.size.should(eq(43)))
          jwk.y.try(&.size.should(eq(43)))
        ensure
          Authly.config.algorithm = original_algorithm
          Authly.config.public_key = original_public_key
        end
      end
    end

    context "with empty public key" do
      it "returns empty keys array for RSA" do
        original_algorithm = Authly.config.algorithm
        original_public_key = Authly.config.public_key

        begin
          Authly.config.algorithm = JWT::Algorithm::RS256
          Authly.config.public_key = ""

          keys = Authority::JWKSService.jwks
          keys.should be_empty
        ensure
          Authly.config.algorithm = original_algorithm
          Authly.config.public_key = original_public_key
        end
      end
    end
  end
end

describe Authority::JWK do
  describe "JSON serialization" do
    it "serializes RSA key correctly" do
      jwk = Authority::JWK.new(
        kty: "RSA",
        use: "sig",
        alg: "RS256",
        kid: "test-key-id",
        n: "modulus",
        e: "AQAB"
      )

      json = jwk.to_json
      parsed = JSON.parse(json)

      parsed["kty"].should eq "RSA"
      parsed["use"].should eq "sig"
      parsed["alg"].should eq "RS256"
      parsed["kid"].should eq "test-key-id"
      parsed["n"].should eq "modulus"
      parsed["e"].should eq "AQAB"
    end

    it "serializes EC key correctly" do
      jwk = Authority::JWK.new(
        kty: "EC",
        use: "sig",
        alg: "ES256",
        kid: "test-ec-key",
        crv: "P-256",
        x: "x-coordinate",
        y: "y-coordinate"
      )

      json = jwk.to_json
      parsed = JSON.parse(json)

      parsed["kty"].should eq "EC"
      parsed["crv"].should eq "P-256"
      parsed["x"].should eq "x-coordinate"
      parsed["y"].should eq "y-coordinate"
    end

    it "omits nil fields" do
      jwk = Authority::JWK.new(kty: "RSA")
      json = jwk.to_json

      json.should_not contain "\"n\":"
      json.should_not contain "\"e\":"
      json.should_not contain "\"crv\":"
    end
  end
end
