# Model Docs - https://clear.gitbook.io/project/model/column-types
module Authority
  class JWT
    include Clear::Model
    self.table = "jwts"

    primary_key
    column client_id : String
    column subject : String
    column publick_key : String

    timestamps
  end
end
