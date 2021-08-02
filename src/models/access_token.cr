# Model Docs - https://clear.gitbook.io/project/model/column-types
module Authority
  class AccessToken
    include Clear::Model
    self.table = "access_tokens"

    primary_key
    column access_token : String
    column client_id : String
    column user_id : String
    column expires : Time
    column scope : String

    timestamps
  end
end
