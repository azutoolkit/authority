# Client Secret Service
# Provides secure hashing and verification of OAuth client secrets using bcrypt.
# Never store client secrets in plaintext - always hash them.
require "crypto/bcrypt/password"

module Authority
  module ClientSecretService
    # Default cost factor for bcrypt (10 is recommended for 2024+)
    BCRYPT_COST = 10

    # Hash a client secret using bcrypt.
    #
    # @param secret [String] The plaintext client secret
    # @return [String] The bcrypt hash of the secret
    def self.hash(secret : String) : String
      Crypto::Bcrypt::Password.create(secret, cost: BCRYPT_COST).to_s
    end

    # Verify a client secret against its hash.
    # Uses timing-safe comparison internally via bcrypt.
    #
    # @param secret [String] The plaintext secret to verify
    # @param hash [String] The bcrypt hash to verify against
    # @return [Bool] True if the secret matches the hash
    def self.verify(secret : String, hash : String) : Bool
      return false if secret.empty? || hash.empty?
      return false unless hash.starts_with?("$2")

      password = Crypto::Bcrypt::Password.new(hash)
      password.verify(secret)
    rescue Crypto::Bcrypt::Error
      false
    end

    # Generate a cryptographically secure random client secret.
    #
    # @param bytes [Int32] Number of random bytes (will be base64 encoded)
    # @return [String] URL-safe base64 encoded random secret
    def self.generate(bytes : Int32 = 32) : String
      Base64.urlsafe_encode(Random::Secure.random_bytes(bytes), padding: false)
    end
  end
end
