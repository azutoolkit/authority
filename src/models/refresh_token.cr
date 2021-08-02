# Model Docs - https://clear.gitbook.io/project/model/column-types
module Authority
  class RefreshToken
    include Clear::Model
    self.table = "refresh_tokens"

    primary_key
    column refresh_token : String
    column client_id : String
    column user_id : String
    column expires : Time
    column scope : String

    timestamps
  end
end
