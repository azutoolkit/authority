module Authority
  struct UserSession
    include Session::SessionData

    property user_id : String = ""
    property email : String = ""
    property id_token : String = ""
    property access_token : String = ""
    property? authenticated : Bool = false

    # MFA tracking
    property mfa_pending_user_id : String = ""
    property mfa_forward_url : String = ""
  end
end
