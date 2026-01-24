# Endpoint for Admin User Session Revocation (All)
# POST /dashboard/users/:id/sessions/revoke-all - Revoke all sessions for a user
module Authority::Dashboard::Users
  class RevokeAllSessionsEndpoint
    include SessionHelper
    include SecurityHeadersHelper
    include AdminAuthHelper
    include Endpoint(ShowRequest, Response)

    post "/dashboard/users/:id/sessions/revoke-all"

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

      user_id = show_request.id

      # Revoke all sessions for this user
      revoked_count = SessionManagementService.revoke_all_for_user(
        user_id: user_id,
        actor: admin_user
      )

      redirect to: "/dashboard/users/#{user_id}?success=Revoked+#{revoked_count}+sessions", status: 302
    end
  end
end
