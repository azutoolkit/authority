# Admin Scope Management Service
# Provides CRUD operations for OAuth scopes with audit logging support.
# Follows the Class + Result pattern consistent with AdminClientService.
module Authority
  class AdminScopeService
    # Result struct for service operations
    struct Result
      getter? success : Bool
      getter scope : Scope?
      getter error : String?
      getter error_code : String?

      def initialize(
        @success : Bool,
        @scope : Scope? = nil,
        @error : String? = nil,
        @error_code : String? = nil
      )
      end
    end

    # List all scopes with pagination
    def self.list(page : Int32 = 1, per_page : Int32 = 20) : Array(Scope)
      offset = (page - 1) * per_page
      results = [] of Scope

      AuthorityDB.exec_query do |conn|
        conn.query(
          "SELECT id, name, display_name, description, is_default, is_system, " \
          "created_at, updated_at " \
          "FROM oauth_scopes ORDER BY is_system DESC, name ASC LIMIT $1 OFFSET $2",
          per_page, offset
        ) do |rs|
          rs.each do
            scope = Scope.new
            scope.id = rs.read(UUID)
            scope.name = rs.read(String)
            scope.display_name = rs.read(String)
            scope.description = rs.read(String?)
            scope.is_default = rs.read(Bool?) || false
            scope.is_system = rs.read(Bool?) || false
            scope.created_at = rs.read(Time?)
            scope.updated_at = rs.read(Time?)
            results << scope
          end
        end
      end

      results
    end

    # Get total count of scopes
    def self.count : Int64
      count = 0_i64
      AuthorityDB.exec_query do |conn|
        count = conn.scalar("SELECT COUNT(*) FROM oauth_scopes").as(Int64)
      end
      count
    end

    # Get a single scope by ID
    def self.get(id : String) : Scope?
      scope = nil

      AuthorityDB.exec_query do |conn|
        conn.query_one?(
          "SELECT id, name, display_name, description, is_default, is_system, " \
          "created_at, updated_at " \
          "FROM oauth_scopes WHERE id = $1::uuid",
          id
        ) do |rs|
          s = Scope.new
          s.id = rs.read(UUID)
          s.name = rs.read(String)
          s.display_name = rs.read(String)
          s.description = rs.read(String?)
          s.is_default = rs.read(Bool?) || false
          s.is_system = rs.read(Bool?) || false
          s.created_at = rs.read(Time?)
          s.updated_at = rs.read(Time?)
          scope = s
        end
      end

      scope
    end

    # Get a scope by name
    def self.get_by_name(name : String) : Scope?
      scope = nil

      AuthorityDB.exec_query do |conn|
        conn.query_one?(
          "SELECT id, name, display_name, description, is_default, is_system, " \
          "created_at, updated_at " \
          "FROM oauth_scopes WHERE name = $1",
          name
        ) do |rs|
          s = Scope.new
          s.id = rs.read(UUID)
          s.name = rs.read(String)
          s.display_name = rs.read(String)
          s.description = rs.read(String?)
          s.is_default = rs.read(Bool?) || false
          s.is_system = rs.read(Bool?) || false
          s.created_at = rs.read(Time?)
          s.updated_at = rs.read(Time?)
          scope = s
        end
      end

      scope
    end

    # Get all default scopes
    def self.default_scopes : Array(Scope)
      results = [] of Scope

      AuthorityDB.exec_query do |conn|
        conn.query(
          "SELECT id, name, display_name, description, is_default, is_system, " \
          "created_at, updated_at " \
          "FROM oauth_scopes WHERE is_default = true ORDER BY name ASC"
        ) do |rs|
          rs.each do
            scope = Scope.new
            scope.id = rs.read(UUID)
            scope.name = rs.read(String)
            scope.display_name = rs.read(String)
            scope.description = rs.read(String?)
            scope.is_default = rs.read(Bool?) || false
            scope.is_system = rs.read(Bool?) || false
            scope.created_at = rs.read(Time?)
            scope.updated_at = rs.read(Time?)
            results << scope
          end
        end
      end

      results
    end

    # Create a new scope
    def self.create(
      name : String,
      display_name : String,
      description : String? = nil,
      is_default : Bool = false,
      actor : User? = nil,
      ip_address : String? = nil
    ) : Result
      # Validate required fields
      return Result.new(success: false, error: "Name is required", error_code: "validation_error") if name.empty?
      return Result.new(success: false, error: "Display name is required", error_code: "validation_error") if display_name.empty?

      # Validate name format (lowercase, alphanumeric, underscores, colons)
      unless name.matches?(/\A[a-z0-9_:]+\z/)
        return Result.new(success: false, error: "Name must be lowercase alphanumeric with underscores or colons", error_code: "invalid_name")
      end

      # Check for duplicate name
      if exists_by_name?(name)
        return Result.new(success: false, error: "Scope name already exists", error_code: "duplicate_name")
      end

      now = Time.utc
      id = UUID.random.to_s

      AuthorityDB.exec_query do |conn|
        conn.exec("BEGIN")
        begin
          conn.exec(
            "INSERT INTO oauth_scopes (id, name, display_name, description, is_default, is_system, " \
            "created_at, updated_at) " \
            "VALUES ($1, $2, $3, $4, $5, false, $6, $7)",
            id, name, display_name, description, is_default, now, now
          )
          conn.exec("COMMIT")
        rescue e
          conn.exec("ROLLBACK")
          raise e
        end
      end

      created_scope = get(id)
      Result.new(success: true, scope: created_scope)
    rescue e
      Result.new(success: false, error: e.message, error_code: "create_failed")
    end

    # Update scope metadata
    def self.update(
      id : String,
      name : String? = nil,
      display_name : String? = nil,
      description : String? = nil,
      is_default : Bool? = nil,
      actor : User? = nil,
      ip_address : String? = nil
    ) : Result
      scope = get(id)
      return Result.new(success: false, error: "Scope not found", error_code: "not_found") unless scope

      # Cannot modify system scopes
      if scope.is_system?
        return Result.new(success: false, error: "System scopes cannot be modified", error_code: "system_scope_protected")
      end

      # Validate name format if changing
      if name && !name.empty? && !name.matches?(/\A[a-z0-9_:]+\z/)
        return Result.new(success: false, error: "Name must be lowercase alphanumeric with underscores or colons", error_code: "invalid_name")
      end

      # Check for duplicate name if changing
      if name && name != scope.name && exists_by_name?(name)
        return Result.new(success: false, error: "Scope name already exists", error_code: "duplicate_name")
      end

      # Build update query dynamically
      updates = [] of String
      params = [] of String | Time | Bool | Nil
      param_idx = 1

      if name && !name.empty?
        updates << "name = $#{param_idx}"
        params << name
        param_idx += 1
      end

      if display_name && !display_name.empty?
        updates << "display_name = $#{param_idx}"
        params << display_name
        param_idx += 1
      end

      if description
        updates << "description = $#{param_idx}"
        params << description
        param_idx += 1
      end

      unless is_default.nil?
        updates << "is_default = $#{param_idx}"
        params << is_default
        param_idx += 1
      end

      updates << "updated_at = $#{param_idx}"
      params << Time.utc
      param_idx += 1

      params << id

      return Result.new(success: true, scope: scope) if updates.size == 1 # Only updated_at

      AuthorityDB.exec_query do |conn|
        conn.exec("BEGIN")
        begin
          conn.exec(
            "UPDATE oauth_scopes SET #{updates.join(", ")} WHERE id = $#{param_idx}::uuid",
            args: params
          )
          conn.exec("COMMIT")
        rescue e
          conn.exec("ROLLBACK")
          raise e
        end
      end

      updated_scope = get(id)
      Result.new(success: true, scope: updated_scope)
    rescue e
      Result.new(success: false, error: e.message, error_code: "update_failed")
    end

    # Delete a scope
    def self.delete(
      id : String,
      actor : User,
      ip_address : String? = nil
    ) : Result
      scope = get(id)
      return Result.new(success: false, error: "Scope not found", error_code: "not_found") unless scope

      # Cannot delete system scopes
      if scope.is_system?
        return Result.new(success: false, error: "System scopes cannot be deleted", error_code: "system_scope_protected")
      end

      AuthorityDB.exec_query do |conn|
        conn.exec("BEGIN")
        begin
          conn.exec("DELETE FROM oauth_scopes WHERE id = $1::uuid", id)
          conn.exec("COMMIT")
        rescue e
          conn.exec("ROLLBACK")
          raise e
        end
      end

      Result.new(success: true)
    rescue e
      Result.new(success: false, error: e.message, error_code: "delete_failed")
    end

    # Check if scope name exists
    private def self.exists_by_name?(name : String) : Bool
      count = 0_i64
      AuthorityDB.exec_query do |conn|
        count = conn.scalar("SELECT COUNT(*) FROM oauth_scopes WHERE name = $1", name).as(Int64)
      end
      count > 0
    end
  end
end
