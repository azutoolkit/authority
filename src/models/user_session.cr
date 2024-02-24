module Authority
  struct UserSession
    include Session::Databag

    property user_id : String = ""
    property email : String = ""
    property id_token : String = ""
    property access_token : String = ""
    property? authenticated : Bool = false
  end
end
