# Request for initiating social OAuth flow
module Authority::Social
  struct AuthorizeRequest
    include Request

    getter provider : String = ""
    getter forward_url : String = Base64.urlsafe_encode("/profile")

    validate provider, message: "Provider must be present.", presence: true
  end
end
