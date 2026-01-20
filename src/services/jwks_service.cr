# JWKS Service (RFC 7517)
# Extracts public key components for JSON Web Key Set
module Authority
  class JWKSService
    # Get the JSON Web Key Set for the current configuration
    def self.jwks : Array(JWK)
      algorithm = Authly.config.algorithm

      case algorithm
      when JWT::Algorithm::HS256, JWT::Algorithm::HS384, JWT::Algorithm::HS512
        # Symmetric keys are not published in JWKS
        [] of JWK
      when JWT::Algorithm::RS256, JWT::Algorithm::RS384, JWT::Algorithm::RS512
        build_rsa_jwks(algorithm)
      when JWT::Algorithm::ES256, JWT::Algorithm::ES384, JWT::Algorithm::ES512
        build_ec_jwks(algorithm)
      else
        [] of JWK
      end
    end

    # Build JWK for RSA keys
    private def self.build_rsa_jwks(algorithm : JWT::Algorithm) : Array(JWK)
      public_key_pem = Authly.config.public_key
      return [] of JWK if public_key_pem.empty?

      begin
        rsa = OpenSSL::PKey::RSA.new(public_key_pem)
        n, e = extract_rsa_components(rsa)

        [JWK.new(
          kty: "RSA",
          use: "sig",
          alg: algorithm.to_s,
          kid: generate_key_id(n, e),
          n: base64url_encode(n),
          e: base64url_encode(e)
        )]
      rescue ex
        [] of JWK
      end
    end

    # Build JWK for EC keys
    private def self.build_ec_jwks(algorithm : JWT::Algorithm) : Array(JWK)
      public_key_pem = Authly.config.public_key
      return [] of JWK if public_key_pem.empty?

      begin
        ec = OpenSSL::PKey::EC.new(public_key_pem)
        x, y, crv = extract_ec_components(ec, algorithm)

        [JWK.new(
          kty: "EC",
          use: "sig",
          alg: algorithm.to_s,
          kid: generate_ec_key_id(x, y),
          crv: crv,
          x: base64url_encode(x),
          y: base64url_encode(y)
        )]
      rescue ex
        [] of JWK
      end
    end

    # Extract RSA modulus (n) and exponent (e) from key
    private def self.extract_rsa_components(rsa : OpenSSL::PKey::RSA) : Tuple(Bytes, Bytes)
      # Get the RSA key pointer
      rsa_ptr = LibCrypto.evp_pkey_get1_rsa(rsa.to_unsafe)

      # Pointers for n, e (will be set by rsa_get0_key)
      n_ptr = Pointer(LibCrypto::Bignum).null
      e_ptr = Pointer(LibCrypto::Bignum).null

      # Get RSA key components
      LibCrypto.rsa_get0_key(rsa_ptr, pointerof(n_ptr), pointerof(e_ptr), nil)

      # Convert to bytes
      n_bn = OpenSSL::BN.new(n_ptr)
      e_bn = OpenSSL::BN.new(e_ptr)

      {n_bn.to_bin, e_bn.to_bin}
    end

    # Extract EC x, y coordinates and curve name
    private def self.extract_ec_components(ec : OpenSSL::PKey::EC, algorithm : JWT::Algorithm) : Tuple(Bytes, Bytes, String)
      # Get public key bytes (uncompressed format: 0x04 + x + y)
      pub_bytes = ec.public_key_bytes

      # Determine curve and coordinate size
      crv, coord_size = case algorithm
                        when JWT::Algorithm::ES256 then {"P-256", 32}
                        when JWT::Algorithm::ES384 then {"P-384", 48}
                        when JWT::Algorithm::ES512 then {"P-521", 66}
                        else                            {"P-256", 32}
                        end

      # Extract x and y (skip the 0x04 prefix byte)
      x = pub_bytes[1, coord_size]
      y = pub_bytes[1 + coord_size, coord_size]

      {x, y, crv}
    end

    # Generate a key ID from RSA components (SHA-256 thumbprint)
    private def self.generate_key_id(n : Bytes, e : Bytes) : String
      # Create canonical JWK for thumbprint (RFC 7638)
      canonical = {
        "e"   => base64url_encode(e),
        "kty" => "RSA",
        "n"   => base64url_encode(n),
      }.to_json

      # SHA-256 hash, base64url encoded
      hash = OpenSSL::Digest.new("SHA256").update(canonical).final
      base64url_encode(hash)
    end

    # Generate a key ID from EC components
    private def self.generate_ec_key_id(x : Bytes, y : Bytes) : String
      combined = String.build do |str|
        str << base64url_encode(x)
        str << base64url_encode(y)
      end
      hash = OpenSSL::Digest.new("SHA256").update(combined).final
      base64url_encode(hash)
    end

    # Base64 URL encode without padding
    private def self.base64url_encode(data : Bytes) : String
      Base64.urlsafe_encode(data, padding: false)
    end
  end

  # JWK structure for JSON serialization
  struct JWK
    include JSON::Serializable

    property kty : String          # Key Type (RSA, EC)
    property use : String?         # Public Key Use (sig, enc)
    property alg : String?         # Algorithm
    property kid : String?         # Key ID
    property n : String?           # RSA modulus
    property e : String?           # RSA exponent
    property crv : String?         # EC curve
    property x : String?           # EC x coordinate
    property y : String?           # EC y coordinate

    def initialize(
      @kty : String,
      @use : String? = nil,
      @alg : String? = nil,
      @kid : String? = nil,
      @n : String? = nil,
      @e : String? = nil,
      @crv : String? = nil,
      @x : String? = nil,
      @y : String? = nil
    )
    end
  end
end
