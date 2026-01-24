# Endpoint Docs https://azutopia.gitbook.io/azu/endpoints
module Authority::Sessions
  class NewEndpoint
    include SecurityHeadersHelper
    include Endpoint(CreateRequest, FormResponse)

    get SIGNIN_PATH

    def call : FormResponse
      set_security_headers!
      header "Content-Type", "text/html; charset=UTF-8"
      header "Cache-Control", "no-store"
      header "Pragma", "no-cache"

      FormResponse.new(
        forward_url: create_request.forward_url,
        google_enabled: SocialOAuthService.provider_enabled?("google"),
        github_enabled: SocialOAuthService.provider_enabled?("github"),
        facebook_enabled: SocialOAuthService.provider_enabled?("facebook"),
        apple_enabled: SocialOAuthService.provider_enabled?("apple"),
        linkedin_enabled: SocialOAuthService.provider_enabled?("linkedin")
      )
    end
  end
end
