module Authority
  struct UserSession
    include Session::Databag
    property user_id : String = ""
    property email : String = ""
    property? authenticated : Bool = false
  end
end
