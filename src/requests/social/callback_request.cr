# Request for handling social OAuth callback
module Authority::Social
  struct CallbackRequest
    include Request

    getter provider : String = ""
    getter code : String = ""
    getter state : String = ""
    getter error : String = ""
    getter error_description : String = ""

    validate provider, message: "Provider must be present.", presence: true
  end
end
