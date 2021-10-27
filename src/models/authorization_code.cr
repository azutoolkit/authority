# Model Docs - https://clear.gitbook.io/project/model/column-types
module Authority
  class AuthorizationCode
    include Clear::Model

    self.table = "authorization_codes"

    primary_key

    column authorization_code : String
    column client_id : String
    column user_id : String
    column redirect_uri : String
    column expires : Time
    column scope : String
    column id_token : String
    column code_challenge : String?, presence: false
    column code_challenge_method : String?, presence: false

    column created_at : Time, presence: false
    column updated_at : Time, presence: false

    def expired?
      Time.utc > expires
    end
  end
end