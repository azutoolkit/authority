module Authority::MFA
  struct SetupRequest
    include Request
  end

  struct EnableRequest
    include Request

    getter code : String = ""
    getter secret : String = ""
    getter backup_codes : String = "" # JSON array

    validate code, message: "Verification code is required", presence: true
    validate secret, message: "Secret is required", presence: true
  end

  struct VerifyRequest
    include Request

    getter code : String = ""
    getter forward_url : String = ""

    validate code, message: "Code is required", presence: true
  end

  struct DisableRequest
    include Request

    getter code : String = ""

    validate code, message: "Code is required to disable MFA", presence: true
  end
end
