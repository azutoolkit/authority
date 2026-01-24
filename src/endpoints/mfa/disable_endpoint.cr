# MFA Disable Endpoint
# GET /mfa/disable - Display MFA disable confirmation
# POST /mfa/disable - Disable MFA after code verification
module Authority::MFA
  class DisableShowEndpoint
    include SessionHelper
    include SecurityHeadersHelper
    include Endpoint(DisableRequest, DisableResponse | Response)

    get "/mfa/disable"

    def call : DisableResponse | Response
      set_security_headers!
      header "Content-Type", "text/html; charset=UTF-8"
      header "Cache-Control", "no-store"

      return redirect_to_signin unless authenticated?

      user = OwnerRepo.find_by_id(current_session.user_id)
      return redirect_to_signin unless user

      # If MFA is not enabled, redirect to profile
      unless user.mfa_enabled
        return redirect to: "/profile", status: 302
      end

      DisableResponse.new(username: user.username)
    end
  end

  class DisableEndpoint
    include SessionHelper
    include SecurityHeadersHelper
    include Endpoint(DisableRequest, DisableResponse | Response)

    post "/mfa/disable"

    def call : DisableResponse | Response
      set_security_headers!
      header "Content-Type", "text/html; charset=UTF-8"
      header "Cache-Control", "no-store"

      return redirect_to_signin unless authenticated?

      user = OwnerRepo.find_by_id(current_session.user_id)
      return redirect_to_signin unless user

      # Validate request
      unless disable_request.valid?
        return DisableResponse.new(
          username: user.username,
          errors: disable_request.errors.map { |e| e.message }
        )
      end

      # Verify the code first
      result = TOTPService.verify_user_code(user, disable_request.code)

      unless result.success?
        return DisableResponse.new(
          username: user.username,
          errors: [result.error || "Invalid code"]
        )
      end

      # Disable MFA
      disable_result = TOTPService.disable(user)

      unless disable_result.success?
        return DisableResponse.new(
          username: user.username,
          errors: [disable_result.error || "Failed to disable MFA"]
        )
      end

      Log.info { "MFA disabled for user: #{user.username}" }

      # Log audit trail
      AuditService.log_system(
        action: "mfa_disabled",
        resource_type: AuditLog::ResourceTypes::USER,
        resource_id: user.id.to_s,
        resource_name: user.username
      )

      redirect to: "/profile?success=mfa_disabled", status: 302
    end
  end
end
