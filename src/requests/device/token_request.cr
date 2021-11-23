module Authority::Device
  struct TokenRequest
    include Request
    getter grant_type : String
    getter client_id : String
    getter code : String
  end
end
