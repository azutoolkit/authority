module Authority
  @[Crinja::Attributes(expose: [id_str, name, display_name, description, default_scope, system_scope, created_at, updated_at, protected?])]
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

    # Returns UUID as string for template rendering
    def id_str : String
      id.to_s
    end

    # System scopes cannot be modified or deleted
    def protected? : Bool
      is_system?
    end

    # Alias methods for Crinja template access (without ? suffix)
    def default_scope : Bool
      is_default?
    end

    def system_scope : Bool
      is_system?
    end
  end
end
