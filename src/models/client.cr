module Authority
  class Client
    include CQL::ActiveRecord::Model(UUID)
    db_context AuthorityDB, :oauth_clients

    property name : String = ""
    property client_id : String = ""
    property client_secret : String = ""
    property redirect_uri : String = ""
    property description : String?
    property logo : String = ""
    property scopes : String = ""
    property policy_url : String?
    property tos_url : String?
    property owner_id : UUID?
    property? is_confidential : Bool = true
    property created_at : Time?
    property updated_at : Time?

    def initialize
    end
  end
end
