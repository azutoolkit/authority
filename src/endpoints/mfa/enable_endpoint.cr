# MFA Enable Endpoint
# POST /mfa/enable - Enable MFA after verification
module Authority::MFA
  class EnableEndpoint
    include SessionHelper
    include SecurityHeadersHelper
    include Endpoint(EnableRequest, SetupResponse | Response)

    post "/mfa/enable"

    def call : SetupResponse | Response
      set_security_headers!
      header "Content-Type", "text/html; charset=UTF-8"
      header "Cache-Control", "no-store"

      return redirect_to_signin unless authenticated?

      user = OwnerRepo.find_by_id(current_session.user_id)
      return redirect_to_signin unless user

      # Validate request
      unless enable_request.valid?
        errors = enable_request.errors.map(&.message)
        return redirect to: "/mfa/setup?error=#{errors.first}", status: 302
      end

      # Parse backup codes from JSON
      backup_codes = begin
        Array(String).from_json(enable_request.backup_codes)
      rescue
        return redirect to: "/mfa/setup?error=invalid_backup_codes", status: 302
      end

      # Enable MFA
      result = TOTPService.enable(
        user,
        enable_request.secret,
        backup_codes,
        enable_request.code
      )

      unless result.success?
        # Re-display setup page with error
        TOTPService.setup(user)
        return SetupResponse.new(
          username: user.username,
          secret: enable_request.secret,
          qr_uri: TOTPService.generate_qr_uri(enable_request.secret, user.email),
          backup_codes: backup_codes,
          errors: [result.error || "Verification failed"]
        )
      end

      Log.info { "MFA enabled for user: #{user.username}" }

      # Log audit trail
      AuditService.log_system(
        action: "mfa_enabled",
        resource_type: AuditLog::ResourceTypes::USER,
        resource_id: user.id.to_s,
        resource_name: user.username
      )

      redirect to: "/profile?success=mfa_enabled", status: 302
    end
  end
end
