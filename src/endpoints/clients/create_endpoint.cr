module Authority::Clients
  class CreateEndpoint
    include SessionHelper
    include SecurityHeadersHelper
    include AdminAuthHelper
    include Endpoint(Clients::NewRequest, FormResponse | Response)

    post "/clients"

    def call : FormResponse | Response
      set_security_headers!

      # Check admin authorization
      if auth_error = require_admin!
        return auth_error
      end

      user = current_admin_user
      return forbidden_response("Admin access required") unless user

      return owner_error(user.username) unless new_request.valid?
      client = ClientRepo.create!(new_request)
      redirect to: "/clients/#{client.id}"
    rescue e
      user = current_admin_user
      owner_error(user.try(&.username) || "", [e.message.to_s])
    end

    private def owner_error(username : String, errors : Array(String) = owner_errors_html)
      status 400
      FormResponse.new new_request, errors, username
    end

    private def owner_errors_html
      new_request.errors.map do |error|
        "<b>#{error.field}:</b> #{error.message}"
      end
    end
  end
end
