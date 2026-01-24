# Endpoint for Admin User Session Revocation
# POST /dashboard/users/:id/sessions/:session_id/revoke - Revoke a specific session
module Authority::Dashboard::Users
  class RevokeSessionEndpoint
    include SessionHelper
    include SecurityHeadersHelper
    include AdminAuthHelper
    include Endpoint(RevokeSessionRequest, Response)

    post "/dashboard/users/:id/sessions/:session_id/revoke"

    def call : Response
      set_security_headers!
      header "Content-Type", "text/html; charset=UTF-8"
      header "Cache-Control", "no-store"
      header "Pragma", "no-cache"

      # Check admin authorization
      if auth_error = require_admin!
        return auth_error
      end

      admin_user = current_admin_user
      return forbidden_response("Admin access required") unless admin_user

      user_id = revoke_session_request.id
      session_id = revoke_session_request.session_id

      # Revoke the session
      result = SessionManagementService.revoke(
        session_id: session_id,
        actor: admin_user
      )

      if result.success?
        redirect to: "/dashboard/users/#{user_id}?success=Session+revoked", status: 302
      else
        redirect to: "/dashboard/users/#{user_id}?error=#{URI.encode_path(result.error || "Failed to revoke session")}", status: 302
      end
    end
  end
end
