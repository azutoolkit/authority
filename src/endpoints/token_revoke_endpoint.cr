# module Authority
#   # GET /revoke
#   # ?client_id=CLIENT_ID&client_secret=CLIENT_SECRET&token=ACCESS_TOKEN
#   class RevokeEndpoint
#     include Endpoint(AuthorizeRequest, AuthorizeResponse)

#     post "/oauth2/revoke"

#     def call : AuthorizeResponse
#     end
#   end
# end
