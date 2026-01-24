# Endpoint for Admin User Bulk Operations
# POST /dashboard/users/bulk - Perform bulk operations on users
module Authority::Dashboard::Users
  class BulkEndpoint
    include SessionHelper
    include SecurityHeadersHelper
    include AdminAuthHelper
    include Endpoint(BulkRequest, Response)

    post "/dashboard/users/bulk"

    def call : Response
      set_security_headers!
      header "Cache-Control", "no-store"
      header "Pragma", "no-cache"

      if auth_error = require_admin!
        return auth_error
      end

      admin_user = current_admin_user
      return forbidden_response("Admin access required") unless admin_user

      return redirect_with_error("No users selected") if bulk_request.ids.empty?

      perform_bulk_action(admin_user)
    end

    private def perform_bulk_action(admin_user : User) : Response
      case bulk_request.action
      when "lock"   then handle_lock(admin_user)
      when "unlock" then handle_unlock(admin_user)
      when "delete" then handle_delete(admin_user)
      when "export" then handle_export
      else
        redirect_with_error("Unknown action: #{bulk_request.action}")
      end
    end

    private def handle_lock(admin_user : User) : Response
      reason = bulk_request.reason.empty? ? "Bulk lock by admin" : bulk_request.reason
      result = AdminUserService.bulk_lock(bulk_request.ids, reason, admin_user)
      build_action_redirect(result, "Locked")
    end

    private def handle_unlock(admin_user : User) : Response
      result = AdminUserService.bulk_unlock(bulk_request.ids, admin_user)
      build_action_redirect(result, "Unlocked")
    end

    private def handle_delete(admin_user : User) : Response
      result = AdminUserService.bulk_delete(bulk_request.ids, admin_user)
      build_action_redirect(result, "Deleted")
    end

    private def handle_export : Response
      export_result = ExportService.export_users_by_ids(bulk_request.ids)
      if export_result.success? && (content = export_result.content)
        header "Content-Type", "text/csv; charset=UTF-8"
        header "Content-Disposition", "attachment; filename=\"#{export_result.filename}\""
        CsvResponse.new(content)
      else
        redirect_with_error("Export failed: #{export_result.error}")
      end
    end

    private def build_action_redirect(result, action_verb : String) : Response
      if result.success?
        redirect to: "/dashboard/users?success=#{action_verb}+#{result.succeeded}+users", status: 302
      else
        redirect to: "/dashboard/users?error=#{action_verb}+#{result.succeeded}+users,+failed+#{result.failed}", status: 302
      end
    end

    private def redirect_with_error(message : String) : Response
      redirect to: "/dashboard/users?error=#{URI.encode_path(message)}", status: 302
    end
  end
end
