# Endpoint Docs https://azutopia.gitbook.io/azu/endpoints
module Authority::Authorize
  class CreateEndpoint
    include Endpoint(NewRequest, Response)
    include SessionHelper

    post "/authorize"

    def call : Response
      # Handle consent denial
      if new_request.consent_denied?
        return redirect to: access_denied_url
      end

      # Store user consent for the requested scopes
      Consent.grant!(
        user_id: current_session.user_id,
        client_id: new_request.client_id,
        scopes: new_request.scope
      )

      redirect to: authorization_code_url
    end

    private def authorization_code_url
      AuthorizationCodeService.new(new_request,
        current_session.user_id).forward_url
    end

    # OAuth2 error response for access denied (RFC 6749 Section 4.1.2.1)
    private def access_denied_url
      uri = URI.parse(new_request.redirect_uri)
      params = uri.query_params
      params["error"] = "access_denied"
      params["error_description"] = "The resource owner denied the request"
      params["state"] = new_request.state
      uri.query_params = params
      uri.to_s
    end
  end
end
