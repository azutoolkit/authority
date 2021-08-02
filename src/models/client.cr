# Model Docs - https://clear.gitbook.io/project/model/column-types
module Authority
  class Client
    include Clear::Model

    self.table = "clients"

    primary_key
    column client_id : String
    column client_secret : String
    column redirect_uri : String
    column grant_types : String
    column scope : String

    timestamps
  end
end
