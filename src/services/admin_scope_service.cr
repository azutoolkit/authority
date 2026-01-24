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
    # Note: Using manual pagination due to CQL query builder issue with limit/offset parameter binding
    def self.list(page : Int32 = 1, per_page : Int32 = 20) : Array(Scope)
      offset = (page - 1) * per_page
      all_scopes = [] of Scope

      Scope.query.order(name: :asc).each do |scope|
        all_scopes << scope
      end

      # Manual pagination
      all_scopes[offset, per_page]? || [] of Scope
    end

    # Get total count of scopes
    def self.count : Int64
      Scope.count.to_i64
    end

    # Get a single scope by ID
    def self.get(id : String) : Scope?
      Scope.find(UUID.new(id))
    rescue
      nil
    end

    # Get a scope by name
    def self.get_by_name(name : String) : Scope?
      Scope.find_by(name: name)
    end

    # Get all default scopes
    def self.default_scopes : Array(Scope)
      results = [] of Scope
      Scope.where(is_default: true).order(name: :asc).each do |scope|
        results << scope
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

      scope = Scope.new
      scope.name = name
      scope.display_name = display_name
      scope.description = description
      scope.is_default = is_default
      scope.is_system = false
      scope.created_at = now
      scope.updated_at = now
      scope.save!

      created_scope = scope

      # Log audit trail
      if created_scope && actor
        AuditService.log(
          actor: actor,
          action: AuditLog::Actions::CREATE,
          resource_type: AuditLog::ResourceTypes::SCOPE,
          resource_id: created_scope.id.to_s,
          resource_name: created_scope.name,
          ip_address: ip_address
        )
      end

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

      validation_error = validate_scope_update(scope, name)
      return validation_error if validation_error

      old_values = capture_scope_values(scope)

      has_changes = apply_scope_updates(scope, name, display_name, description, is_default)
      return Result.new(success: true, scope: scope) unless has_changes

      scope.updated_at = Time.utc
      scope.update!

      log_scope_update_audit(scope, old_values, actor, ip_address)

      Result.new(success: true, scope: scope)
    rescue e
      Result.new(success: false, error: e.message, error_code: "update_failed")
    end

    # Validate scope update constraints
    private def self.validate_scope_update(scope : Scope, name : String?) : Result?
      if scope.is_system?
        return Result.new(success: false, error: "System scopes cannot be modified", error_code: "system_scope_protected")
      end

      if name && !name.empty? && !name.matches?(/\A[a-z0-9_:]+\z/)
        return Result.new(success: false, error: "Name must be lowercase alphanumeric with underscores or colons", error_code: "invalid_name")
      end

      if name && name != scope.name && exists_by_name?(name)
        return Result.new(success: false, error: "Scope name already exists", error_code: "duplicate_name")
      end

      nil
    end

    # Capture current scope values for audit diff
    private def self.capture_scope_values(scope : Scope) : Hash(String, String?)
      {
        "name"         => scope.name,
        "display_name" => scope.display_name,
        "description"  => scope.description,
        "is_default"   => scope.is_default?.to_s,
      } of String => String?
    end

    # Apply updates to scope fields, returns true if any changes were made
    private def self.apply_scope_updates(
      scope : Scope,
      name : String?,
      display_name : String?,
      description : String?,
      is_default : Bool?
    ) : Bool
      has_changes = false

      if name && !name.empty?
        scope.name = name
        has_changes = true
      end

      if display_name && !display_name.empty?
        scope.display_name = display_name
        has_changes = true
      end

      if description
        scope.description = description
        has_changes = true
      end

      unless is_default.nil?
        scope.is_default = is_default
        has_changes = true
      end

      has_changes
    end

    # Log audit trail for scope update
    private def self.log_scope_update_audit(scope : Scope, old_values : Hash(String, String?), actor : User?, ip_address : String?) : Nil
      return unless actor

      new_values = capture_scope_values(scope)
      changes = AuditService.diff(old_values, new_values)

      AuditService.log(
        actor: actor,
        action: AuditLog::Actions::UPDATE,
        resource_type: AuditLog::ResourceTypes::SCOPE,
        resource_id: scope.id.to_s,
        resource_name: scope.name,
        changes: changes,
        ip_address: ip_address
      )
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

      # Capture scope info for audit before deletion
      scope_name = scope.name
      scope_uuid = scope.id

      scope.delete!

      # Log audit trail
      AuditService.log(
        actor: actor,
        action: AuditLog::Actions::DELETE,
        resource_type: AuditLog::ResourceTypes::SCOPE,
        resource_id: scope_uuid.to_s,
        resource_name: scope_name,
        ip_address: ip_address
      )

      Result.new(success: true)
    rescue e
      Result.new(success: false, error: e.message, error_code: "delete_failed")
    end

    # Check if scope name exists
    private def self.exists_by_name?(name : String) : Bool
      Scope.exists?(name: name)
    end
  end
end
