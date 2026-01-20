# Endpoint for Token Validation
# GET /account/token/validate - Check if a recovery token is valid
module Authority::Account
  class TokenValidationEndpoint
    include Endpoint(Nil, TokenValidationResponse)

    get "/account/token/validate"

    def call : TokenValidationResponse
      header "Content-Type", "application/json;charset=UTF-8"
      header "Cache-Control", "no-store"
      header "Pragma", "no-cache"

      token = params["token"]?
      token_type = params["type"]? || "password_reset"

      return TokenValidationResponse.new(false) unless token

      valid = case token_type
              when "password_reset"
                AccountRecoveryService.valid_password_reset_token?(token)
              when "email_verification"
                AccountRecoveryService.valid_email_verification_token?(token)
              else
                false
              end

      TokenValidationResponse.new(valid)
    end
  end
end
