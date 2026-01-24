# Admin Client Management Service
# Provides CRUD operations for OAuth clients with audit logging support.
# Follows the Class + Result pattern consistent with ScopeValidationService.
module Authority
  class AdminClientService
    # Result struct for service operations
    struct Result
      getter? success : Bool
      getter client : Client?
      getter error : String?
      getter error_code : String?

      def initialize(
        @success : Bool,
        @client : Client? = nil,
        @error : String? = nil,
        @error_code : String? = nil
      )
      end
    end

    # List options for filtering
    struct ListOptions
      property page : Int32 = 1
      property per_page : Int32 = 20
      property search : String?
      property confidentiality : String?  # "confidential", "public", nil for all
      property scope : String?            # Filter by specific scope
      property sort_by : String = "created_at"
      property sort_dir : String = "DESC"

      def initialize(
        @page : Int32 = 1,
        @per_page : Int32 = 20,
        @search : String? = nil,
        @confidentiality : String? = nil,
        @scope : String? = nil,
        @sort_by : String = "created_at",
        @sort_dir : String = "DESC"
      )
      end
    end

    # List all clients with pagination and filtering
    def self.list(options : ListOptions = ListOptions.new) : Array(Client)
      offset = (options.page - 1) * options.per_page

      query = Client.query

      # Validate sort column to prevent SQL injection
      valid_sort_columns = ["created_at", "updated_at", "name"]
      sort_column = valid_sort_columns.includes?(options.sort_by) ? options.sort_by : "created_at"
      sort_direction = options.sort_dir.upcase == "ASC" ? :asc : :desc

      # Apply ordering based on validated column
      case sort_column
      when "created_at"
        query = query.order(created_at: sort_direction)
      when "updated_at"
        query = query.order(updated_at: sort_direction)
      when "name"
        query = query.order(name: sort_direction)
      end

      # Fetch all matching clients, then apply in-memory filters
      results = query.all

      # Apply search filter in memory
      if search = options.search
        if !search.empty?
          pattern = search.downcase
          results = results.select do |client|
            client.name.downcase.includes?(pattern) ||
              client.client_id.downcase.includes?(pattern) ||
              client.redirect_uri.downcase.includes?(pattern) ||
              (client.description.try(&.downcase.includes?(pattern)) || false)
          end
        end
      end

      # Apply confidentiality filter
      case options.confidentiality
      when "confidential"
        results = results.select(&.is_confidential)
      when "public"
        results = results.select { |c| !c.is_confidential }
      end

      # Apply scope filter
      if scope = options.scope
        if !scope.empty?
          results = results.select do |client|
            client.scopes_list.includes?(scope)
          end
        end
      end

      # Apply pagination in memory
      results.skip(offset).first(options.per_page)
    end

    # Backwards-compatible list method
    def self.list(page : Int32 = 1, per_page : Int32 = 20) : Array(Client)
      list(ListOptions.new(page: page, per_page: per_page))
    end

    # Count total clients with filters
    def self.count(options : ListOptions = ListOptions.new) : Int64
      list(ListOptions.new(
        page: 1,
        per_page: Int32::MAX,
        search: options.search,
        confidentiality: options.confidentiality,
        scope: options.scope
      )).size.to_i64
    end

    # Get a single client by ID
    def self.get(id : String) : Client?
      Client.find(UUID.new(id))
    rescue
      nil
    end

    # Create a new client with secret hashing
    def self.create(
      name : String,
      redirect_uri : String,
      description : String? = nil,
      logo : String = "",
      scopes : String = "read",
      policy_url : String? = nil,
      tos_url : String? = nil,
      owner_id : String? = nil,
      is_confidential : Bool = true,
      actor : User? = nil,
      ip_address : String? = nil
    ) : Result
      # Generate client credentials
      plain_secret = ClientSecretService.generate
      hashed_secret = ClientSecretService.hash(plain_secret)
      now = Time.utc

      client = Client.new
      client.client_id = UUID.random.to_s
      client.client_secret = hashed_secret
      client.name = name
      client.description = description
      client.logo = logo
      client.redirect_uri = redirect_uri
      client.scopes = scopes
      client.policy_url = policy_url
      client.tos_url = tos_url
      client.owner_id = owner_id.try { |id| UUID.new(id) }
      client.is_confidential = is_confidential
      client.created_at = now
      client.updated_at = now
      client.save!

      created_client = client

      # Log audit trail
      if created_client && actor
        AuditService.log(
          actor: actor,
          action: AuditLog::Actions::CREATE,
          resource_type: AuditLog::ResourceTypes::CLIENT,
          resource_id: created_client.id.to_s,
          resource_name: created_client.name,
          ip_address: ip_address
        )
      end

      Result.new(success: true, client: created_client)
    rescue e
      Result.new(success: false, error: e.message, error_code: "create_failed")
    end

    # Create a new client and return both result and plain secret
    def self.create_with_secret(
      name : String,
      redirect_uri : String,
      description : String? = nil,
      logo : String = "",
      scopes : String = "read",
      policy_url : String? = nil,
      tos_url : String? = nil,
      owner_id : String? = nil,
      is_confidential : Bool = true,
      actor : User? = nil,
      ip_address : String? = nil
    ) : Tuple(Result, String?)
      # Generate client credentials
      plain_secret = ClientSecretService.generate
      hashed_secret = ClientSecretService.hash(plain_secret)
      now = Time.utc

      client = Client.new
      client.client_id = UUID.random.to_s
      client.client_secret = hashed_secret
      client.name = name
      client.description = description
      client.logo = logo
      client.redirect_uri = redirect_uri
      client.scopes = scopes
      client.policy_url = policy_url
      client.tos_url = tos_url
      client.owner_id = owner_id.try { |id| UUID.new(id) }
      client.is_confidential = is_confidential
      client.created_at = now
      client.updated_at = now
      client.save!

      created_client = client

      # Log audit trail
      if created_client && actor
        AuditService.log(
          actor: actor,
          action: AuditLog::Actions::CREATE,
          resource_type: AuditLog::ResourceTypes::CLIENT,
          resource_id: created_client.id.to_s,
          resource_name: created_client.name,
          ip_address: ip_address
        )
      end

      {Result.new(success: true, client: created_client), plain_secret}
    rescue e
      {Result.new(success: false, error: e.message, error_code: "create_failed"), nil}
    end

    # Update client metadata
    def self.update(
      id : String,
      name : String? = nil,
      description : String? = nil,
      logo : String? = nil,
      redirect_uri : String? = nil,
      scopes : String? = nil,
      policy_url : String? = nil,
      tos_url : String? = nil,
      is_confidential : Bool? = nil,
      actor : User? = nil,
      ip_address : String? = nil
    ) : Result
      client = get(id)
      return Result.new(success: false, error: "Client not found", error_code: "not_found") unless client

      # Capture old values for audit diff
      old_values = {
        "name"            => client.name,
        "description"     => client.description,
        "redirect_uri"    => client.redirect_uri,
        "scopes"          => client.scopes,
        "policy_url"      => client.policy_url,
        "tos_url"         => client.tos_url,
        "is_confidential" => client.is_confidential?.to_s,
      } of String => String?

      # Update fields if provided
      has_changes = false

      if name
        client.name = name
        has_changes = true
      end

      if description
        client.description = description
        has_changes = true
      end

      if logo
        client.logo = logo
        has_changes = true
      end

      if redirect_uri
        client.redirect_uri = redirect_uri
        has_changes = true
      end

      if scopes
        client.scopes = scopes
        has_changes = true
      end

      if policy_url
        client.policy_url = policy_url
        has_changes = true
      end

      if tos_url
        client.tos_url = tos_url
        has_changes = true
      end

      unless is_confidential.nil?
        client.is_confidential = is_confidential
        has_changes = true
      end

      return Result.new(success: true, client: client) unless has_changes

      client.updated_at = Time.utc
      client.update!

      updated_client = client

      # Invalidate cache for this client
      if updated_client
        ClientCacheService.invalidate(updated_client.client_id)
      end

      # Log audit trail with changes
      if updated_client && actor
        new_values = {
          "name"            => updated_client.name,
          "description"     => updated_client.description,
          "redirect_uri"    => updated_client.redirect_uri,
          "scopes"          => updated_client.scopes,
          "policy_url"      => updated_client.policy_url,
          "tos_url"         => updated_client.tos_url,
          "is_confidential" => updated_client.is_confidential?.to_s,
        } of String => String?

        changes = AuditService.diff(old_values, new_values)

        AuditService.log(
          actor: actor,
          action: AuditLog::Actions::UPDATE,
          resource_type: AuditLog::ResourceTypes::CLIENT,
          resource_id: updated_client.id.to_s,
          resource_name: updated_client.name,
          changes: changes,
          ip_address: ip_address
        )
      end

      Result.new(success: true, client: updated_client)
    rescue e
      Result.new(success: false, error: e.message, error_code: "update_failed")
    end

    # Delete a client
    def self.delete(
      id : String,
      actor : User,
      ip_address : String? = nil
    ) : Result
      client = get(id)
      return Result.new(success: false, error: "Client not found", error_code: "not_found") unless client

      client_id_value = client.client_id

      # Capture client info for audit before deletion
      client_name = client.name
      client_uuid = client.id

      # Delete associated tokens
      OpaqueToken.where(client_id: client_id_value).delete_all

      # Delete associated consents
      Consent.where(client_id: client_id_value).delete_all

      # Delete client
      client.delete!

      # Invalidate cache for this client
      ClientCacheService.invalidate(client_id_value)

      # Log audit trail
      AuditService.log(
        actor: actor,
        action: AuditLog::Actions::DELETE,
        resource_type: AuditLog::ResourceTypes::CLIENT,
        resource_id: client_uuid.to_s,
        resource_name: client_name,
        ip_address: ip_address
      )

      Result.new(success: true)
    rescue e
      Result.new(success: false, error: e.message, error_code: "delete_failed")
    end

    # Regenerate client secret
    def self.regenerate_secret(
      id : String,
      actor : User,
      ip_address : String? = nil
    ) : Tuple(Result, String?)
      client = get(id)
      return {Result.new(success: false, error: "Client not found", error_code: "not_found"), nil} unless client

      plain_secret = ClientSecretService.generate
      hashed_secret = ClientSecretService.hash(plain_secret)

      client.client_secret = hashed_secret
      client.updated_at = Time.utc
      client.update!

      updated_client = client

      # Invalidate cache for this client
      if updated_client
        ClientCacheService.invalidate(updated_client.client_id)
      end

      # Log audit trail
      if updated_client
        AuditService.log(
          actor: actor,
          action: AuditLog::Actions::REGEN_SECRET,
          resource_type: AuditLog::ResourceTypes::CLIENT,
          resource_id: updated_client.id.to_s,
          resource_name: updated_client.name,
          ip_address: ip_address
        )
      end

      {Result.new(success: true, client: updated_client), plain_secret}
    rescue e
      {Result.new(success: false, error: e.message, error_code: "regenerate_failed"), nil}
    end

    # Bulk result struct
    struct BulkResult
      getter? success : Bool
      getter succeeded : Int32
      getter failed : Int32
      getter errors : Array(String)

      def initialize(
        @success : Bool,
        @succeeded : Int32 = 0,
        @failed : Int32 = 0,
        @errors : Array(String) = [] of String
      )
      end
    end

    # Bulk delete multiple clients
    def self.bulk_delete(
      ids : Array(String),
      actor : User,
      ip_address : String? = nil
    ) : BulkResult
      succeeded = 0
      failed = 0
      errors = [] of String

      ids.each do |id|
        result = delete(id, actor, ip_address)
        if result.success?
          succeeded += 1
        else
          failed += 1
          errors << "Client #{id}: #{result.error}"
        end
      end

      BulkResult.new(
        success: failed == 0,
        succeeded: succeeded,
        failed: failed,
        errors: errors
      )
    end

    # Find client by client_id (UUID string used in OAuth flows)
    private def self.find_by_client_id(client_id : String) : Client?
      Client.find_by(client_id: client_id)
    end
  end
end
