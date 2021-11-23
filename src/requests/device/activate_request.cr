module Authority::Device
  struct ActivateRequest
    include Request
    getter user_code : String = ""
    getter verification : String = ""
    getter audience : String = ""
  end
end
