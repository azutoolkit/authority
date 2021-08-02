# Model Docs - https://clear.gitbook.io/project/model/column-types
module Authority
  class User
    include Clear::Model

    self.table = "users"

    primary_key
    column username : String
    column password : String
    column first_name : String
    column last_name : String
    column email : String
    column email_verified : Bool
    column scope : String

    timestamps
  end
end
