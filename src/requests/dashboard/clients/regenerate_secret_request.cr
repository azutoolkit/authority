# Admin Client Regenerate Secret Request
# Used for regenerating client secret
module Authority::Dashboard::Clients
  struct RegenerateSecretRequest
    include Request

    getter id : String = ""
  end
end
