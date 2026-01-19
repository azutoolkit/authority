module Authority
  class Client
    include CQL::ActiveRecord::Model(String)
    db_context AuthorityDB, :oauth_clients

    property id : String?
    property name : String = ""
    property client_id : String = ""
    property client_secret : String = ""
    property redirect_uri : String = ""
    property description : String?
    property logo : String = ""
    property scopes : String = ""
    property created_at : Time?
    property updated_at : Time?

    # Initialize with default values for new records
    def initialize
    end

    # Override create! to handle UUID primary keys
    def create!
      validate!
      @id ||= UUID.random.to_s
      attrs = attributes
      CQL::Insert
        .new(Client.schema)
        .into(Client.table)
        .values(attrs)
        .commit
      self
    end
  end
end
