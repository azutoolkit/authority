# Endpoint Docs https://azutopia.gitbook.io/azu/endpoints
module Authority::Sessions
  SIGNIN_PATH = "/signin"

  class CreateEndpoint
    include Endpoint(CreateRequest, FormResponse | Response)

    post SIGNIN_PATH

    def call : FormResponse | Response
      return request_error unless create_request.valid?

      ip_address = get_client_ip
      result = AuthenticationService.authenticate(create_request, ip_address)

      if result.success?
        header "Content-Type", "application/json; charset=UTF-8"
        header "Cache-Control", "no-store"
        header "Pragma", "no-cache"

        redirect to: Base64.decode_string(create_request.forward_url), status: 302
      else
        auth_error(result)
      end
    end

    private def request_error(errors = client_errors)
      status 400
      FormResponse.new create_request.forward_url, errors
    end

    private def client_errors
      create_request.errors.map do |error|
        "<b>#{error.field}:</b> #{error.message}"
      end
    end

    private def auth_error(result : AuthenticationService::AuthResult)
      # Set Retry-After header if account is locked
      if retry_after = result.retry_after
        header "Retry-After", retry_after.total_seconds.to_i.to_s
      end

      error_message = result.error || "Invalid credentials"

      # Use 423 Locked status for account locked errors
      status_code = result.error_code == "account_locked" ? 423 : 401

      error "Authentication failed", status_code, [error_message]
    end

    private def unauthorized_error
      error "Invalid client", 401, ["Invalid credentials"]
    end

    # Get client IP from request
    private def get_client_ip : String
      # Check X-Forwarded-For header first (for reverse proxy setups)
      forwarded = context.request.headers["X-Forwarded-For"]?
      if forwarded
        return forwarded.split(",").first.strip
      end

      # Check X-Real-IP header
      real_ip = context.request.headers["X-Real-IP"]?
      return real_ip.strip if real_ip

      # Fall back to remote address
      remote = context.request.remote_address
      case remote
      when Socket::IPAddress
        remote.address
      else
        "127.0.0.1"
      end
    end
  end
end
