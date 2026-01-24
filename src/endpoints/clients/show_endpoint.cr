module Authority::Clients
  class ShowEndpoint
    include SessionHelper
    include SecurityHeadersHelper
    include AdminAuthHelper
    include Endpoint(ShowRequest, ShowResponse | Response)

    get "/clients/:id"

    def call : ShowResponse | Response
      set_security_headers!
      header "Content-Type", "text/html; charset=UTF-8"
      header "Cache-Control", "no-store"
      header "Pragma", "no-cache"

      # Check admin authorization
      if auth_error = require_admin!
        return auth_error
      end

      user = current_admin_user
      return forbidden_response("Admin access required") unless user

      ShowResponse.new client, user.username
    end

    def client
      ClientRepo.get(show_request.id)
    end
  end
end
