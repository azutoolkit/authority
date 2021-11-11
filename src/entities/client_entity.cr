# Model Docs - https://clear.gitbook.io/project/model/column-types
module Authority
  class ClientEntity
    include Clear::Model

    self.table = "clients"

    primary_key :id, type: :uuid

    column name : String
    column client_id : UUID
    column client_secret : String
    column redirect_uri : String
    column description : String
    column name : String
    column logo : String
    column scopes : String

    timestamps
  end
end
