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

      # Check admin authorization
      if auth_error = require_admin!
        return auth_error
      end

      admin_user = current_admin_user
      return forbidden_response("Admin access required") unless admin_user

      ids = bulk_request.ids
      action = bulk_request.action

      # Validate request
      if ids.empty?
        return redirect_with_error("No users selected")
      end

      case action
      when "lock"
        reason = bulk_request.reason.empty? ? "Bulk lock by admin" : bulk_request.reason
        result = AdminUserService.bulk_lock(ids, reason, admin_user)
        if result.success?
          redirect to: "/dashboard/users?success=Locked+#{result.succeeded}+users", status: 302
        else
          redirect to: "/dashboard/users?error=Locked+#{result.succeeded}+users,+failed+#{result.failed}", status: 302
        end

      when "unlock"
        result = AdminUserService.bulk_unlock(ids, admin_user)
        if result.success?
          redirect to: "/dashboard/users?success=Unlocked+#{result.succeeded}+users", status: 302
        else
          redirect to: "/dashboard/users?error=Unlocked+#{result.succeeded}+users,+failed+#{result.failed}", status: 302
        end

      when "delete"
        result = AdminUserService.bulk_delete(ids, admin_user)
        if result.success?
          redirect to: "/dashboard/users?success=Deleted+#{result.succeeded}+users", status: 302
        else
          redirect to: "/dashboard/users?error=Deleted+#{result.succeeded}+users,+failed+#{result.failed}", status: 302
        end

      when "export"
        export_result = ExportService.export_users_by_ids(ids)
        if export_result.success?
          header "Content-Type", "text/csv; charset=UTF-8"
          header "Content-Disposition", "attachment; filename=\"#{export_result.filename}\""
          text export_result.content.not_nil!
        else
          redirect_with_error("Export failed: #{export_result.error}")
        end

      else
        redirect_with_error("Unknown action: #{action}")
      end
    end

    private def redirect_with_error(message : String) : Response
      redirect to: "/dashboard/users?error=#{URI.encode_path(message)}", status: 302
    end
  end
end
