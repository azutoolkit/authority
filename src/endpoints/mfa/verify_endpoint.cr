# MFA Verify Endpoint
# GET /mfa/verify - Display MFA verification form during login
# POST /mfa/verify - Verify MFA code and complete login
module Authority::MFA
  class VerifyShowEndpoint
    include SessionHelper
    include SecurityHeadersHelper
    include Endpoint(VerifyRequest, VerifyResponse | Response)

    get "/mfa/verify"

    def call : VerifyResponse | Response
      set_security_headers!
      header "Content-Type", "text/html; charset=UTF-8"
      header "Cache-Control", "no-store"

      # User must have pending MFA verification
      pending_user_id = current_session.mfa_pending_user_id
      return redirect to: "/signin", status: 302 if pending_user_id.empty?

      user = User.find_by(id: pending_user_id)
      return redirect to: "/signin", status: 302 unless user

      VerifyResponse.new(
        username: user.username,
        forward_url: current_session.mfa_forward_url,
        backup_codes_remaining: TOTPService.backup_codes_remaining(user)
      )
    end
  end

  class VerifyEndpoint
    include SessionHelper
    include SecurityHeadersHelper
    include Endpoint(VerifyRequest, VerifyResponse | Response)

    post "/mfa/verify"

    def call : VerifyResponse | Response
      set_security_headers!
      header "Content-Type", "text/html; charset=UTF-8"
      header "Cache-Control", "no-store"

      # User must have pending MFA verification
      pending_user_id = current_session.mfa_pending_user_id
      return redirect to: "/signin", status: 302 if pending_user_id.empty?

      user = User.find_by(id: pending_user_id)
      return redirect to: "/signin", status: 302 unless user

      # Validate request
      unless verify_request.valid?
        return VerifyResponse.new(
          username: user.username,
          forward_url: verify_request.forward_url,
          backup_codes_remaining: TOTPService.backup_codes_remaining(user),
          errors: ["Code is required"]
        )
      end

      # Verify the code
      result = TOTPService.verify_user_code(user, verify_request.code)

      unless result.success?
        return VerifyResponse.new(
          username: user.username,
          forward_url: verify_request.forward_url,
          backup_codes_remaining: TOTPService.backup_codes_remaining(user),
          errors: [result.error || "Invalid code"]
        )
      end

      # Clear MFA pending state and complete login
      current_session.mfa_pending_user_id = ""
      current_session.mfa_forward_url = ""
      current_session.user_id = user.id.to_s
      current_session.email = user.email
      current_session.authenticated = true

      Log.info { "MFA verification successful for user: #{user.username}#{result.backup_code_used? ? " (backup code used)" : ""}" }

      # Redirect to the forward URL or dashboard
      forward_url = verify_request.forward_url.empty? ? "/" : Base64.decode_string(verify_request.forward_url)
      redirect to: forward_url, status: 302
    end
  end
end
