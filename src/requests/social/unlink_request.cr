# Request for unlinking a social account
module Authority::Social
  struct UnlinkRequest
    include Request

    getter provider : String = ""

    validate provider, message: "Provider must be present.", presence: true
  end
end
