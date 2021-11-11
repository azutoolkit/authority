module Authority::Owner
  struct NewRequest
    include Request

    getter first_name : String = ""
    getter last_name : String = ""
    getter email : String = ""
    getter username : String = ""
    getter password : String = ""
    getter confirm_password : String = ""

    use ConfirmPasswordValidator

    validate first_name, message: "Param first_name must be present.", presence: true
    validate last_name, message: "Param last_name must be present.", presence: true
    validate email, message: "Param email must be present.", presence: true
    validate username, message: "Param username must be present.", presence: true
    validate password, message: "Param password must be present.", presence: true
  end
end
