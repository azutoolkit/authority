# JSON Web Key Set Response (RFC 7517)
# Returns the public keys used to verify token signatures
module Authority
  struct JWKSResponse
    include Response

    def render
      {
        keys: build_keys,
      }.to_json
    end

    private def build_keys : Array(Hash(String, String))
      # For symmetric algorithms (HS256/384/512), we don't expose the secret key
      # The JWKS endpoint returns an empty array since the key is shared out-of-band
      #
      # For asymmetric algorithms (RS256/384/512, ES256/384/512), we would return
      # the public key components here
      case Authly.config.algorithm
      when JWT::Algorithm::HS256, JWT::Algorithm::HS384, JWT::Algorithm::HS512
        # Symmetric keys are not published - shared via client registration
        [] of Hash(String, String)
      else
        # Placeholder for asymmetric key support
        # When RS256/ES256 is configured, extract and return public key components:
        # [
        #   {
        #     "kty" => "RSA",
        #     "use" => "sig",
        #     "kid" => key_id,
        #     "alg" => "RS256",
        #     "n"   => base64url_encode(modulus),
        #     "e"   => base64url_encode(exponent),
        #   }
        # ]
        [] of Hash(String, String)
      end
    end
  end
end
