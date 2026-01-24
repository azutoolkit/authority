# Endpoint to unlink a social account from the user
module Authority::Social
  class UnlinkEndpoint
    include SecurityHeadersHelper
    include SessionHelper
    include Endpoint(UnlinkRequest, Response)

    post "/auth/:provider/unlink"

    def call : Response
      set_security_headers!

      # Require authentication
      unless authenticated?
        return redirect to: "/signin?forward_url=#{Base64.urlsafe_encode("/profile")}", status: 302
      end

      user = current_user
      unless user
        return redirect to: "/signin", status: 302
      end

      provider = unlink_request.provider.downcase

      # Validate provider
      unless SocialConnection::Providers.valid?(provider)
        return error_redirect("Invalid provider: #{provider}")
      end

      # Get user ID (handle nil case)
      user_id = user.id
      unless user_id
        return error_redirect("User ID not found")
      end

      # Unlink the social account
      result = SocialOAuthService.unlink(user_id, provider)

      if result.success?
        redirect to: "/profile?success=#{URI.encode_path_segment("#{provider.capitalize} account unlinked successfully")}", status: 302
      else
        error_redirect(result.error || "Failed to unlink account")
      end
    end

    private def current_user : User?
      user_id = Authority.current_session.user_id
      return nil unless user_id
      User.find(UUID.new(user_id))
    rescue
      nil
    end

    private def error_redirect(message : String) : Response
      encoded_error = URI.encode_path_segment(message)
      redirect to: "/profile?error=#{encoded_error}", status: 302
    end
  end
end
