module Authority
  @[Crinja::Attributes(expose: [id, name, display_name, description, is_default?, is_system?, created_at, updated_at, protected?])]
  class Scope
    include CQL::ActiveRecord::Model(UUID)
    include Crinja::Object::Auto
    db_context AuthorityDB, :oauth_scopes

    property name : String = ""
    property display_name : String = ""
    property description : String?
    property? is_default : Bool = false
    property? is_system : Bool = false
    property created_at : Time?
    property updated_at : Time?

    def initialize
    end

    # System scopes cannot be modified or deleted
    def protected? : Bool
      is_system?
    end
  end
end
