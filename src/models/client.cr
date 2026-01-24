module Authority
  @[Crinja::Attributes(expose: [id_str, name, client_id, client_secret, description, logo, scopes, scopes_list, redirect_uri, policy_url, tos_url, confidential, created_at, updated_at])]
  class Client
    include CQL::ActiveRecord::Model(UUID)
    include Crinja::Object::Auto
    db_context AuthorityDB, :oauth_clients

    property name : String = ""
    property client_id : String = ""
    property client_secret : String = ""
    property redirect_uri : String = ""
    property redirect_uris : String?
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

    # Returns UUID as string for template rendering
    def id_str : String
      id.to_s
    end

    # Returns scopes as array for template iteration
    def scopes_list : Array(String)
      scopes.split(' ').reject(&.empty?)
    end

    # Alias method for Crinja template access (without ? suffix)
    def confidential : Bool
      is_confidential?
    end
  end
end
