# MFA Setup Endpoint
# GET /mfa/setup - Display MFA setup page with QR code
module Authority::MFA
  class SetupEndpoint
    include SessionHelper
    include SecurityHeadersHelper
    include Endpoint(SetupRequest, SetupResponse | Response)

    get "/mfa/setup"

    def call : SetupResponse | Response
      set_security_headers!
      header "Content-Type", "text/html; charset=UTF-8"
      header "Cache-Control", "no-store"
      header "Pragma", "no-cache"

      return redirect_to_signin unless authenticated?

      user = OwnerRepo.find_by_id(current_session.user_id)
      return redirect_to_signin unless user

      # If MFA is already enabled, redirect to profile
      if user.mfa_enabled
        return redirect to: "/profile", status: 302
      end

      # Generate MFA setup data
      result = TOTPService.setup(user)

      unless result.success?
        return redirect to: "/profile?error=mfa_setup_failed", status: 302
      end

      SetupResponse.new(
        username: user.username,
        secret: result.secret.not_nil!,
        qr_uri: result.qr_uri.not_nil!,
        backup_codes: result.backup_codes.not_nil!
      )
    end
  end
end
