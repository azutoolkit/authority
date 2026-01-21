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

    # List all clients with pagination
    def self.list(page : Int32 = 1, per_page : Int32 = 20) : Array(Client)
      offset = (page - 1) * per_page
      results = [] of Client

      AuthorityDB.exec_query do |conn|
        conn.query(
          "SELECT id, client_id, name, description, logo, redirect_uri, scopes, " \
          "policy_url, tos_url, owner_id, is_confidential, created_at, updated_at " \
          "FROM oauth_clients ORDER BY created_at DESC LIMIT $1 OFFSET $2",
          per_page, offset
        ) do |rs|
          rs.each do
            client = Client.new
            client.id = rs.read(UUID)
            client.client_id = rs.read(UUID).to_s
            client.name = rs.read(String)
            client.description = rs.read(String?)
            client.logo = rs.read(String?) || ""
            client.redirect_uri = rs.read(String)
            client.scopes = rs.read(String?) || ""
            client.policy_url = rs.read(String?)
            client.tos_url = rs.read(String?)
            client.owner_id = rs.read(UUID?)
            client.is_confidential = rs.read(Bool?) || true
            client.created_at = rs.read(Time?)
            client.updated_at = rs.read(Time?)
            results << client
          end
        end
      end

      results
    end

    # Get a single client by ID
    def self.get(id : String) : Client?
      client = nil

      AuthorityDB.exec_query do |conn|
        conn.query_one?(
          "SELECT id, client_id, client_secret, name, description, logo, redirect_uri, scopes, " \
          "policy_url, tos_url, owner_id, is_confidential, created_at, updated_at " \
          "FROM oauth_clients WHERE id = $1::uuid",
          id
        ) do |rs|
          c = Client.new
          c.id = rs.read(UUID)
          c.client_id = rs.read(UUID).to_s
          c.client_secret = rs.read(String)
          c.name = rs.read(String)
          c.description = rs.read(String?)
          c.logo = rs.read(String?) || ""
          c.redirect_uri = rs.read(String)
          c.scopes = rs.read(String?) || ""
          c.policy_url = rs.read(String?)
          c.tos_url = rs.read(String?)
          c.owner_id = rs.read(UUID?)
          c.is_confidential = rs.read(Bool?) || true
          c.created_at = rs.read(Time?)
          c.updated_at = rs.read(Time?)
          client = c
        end
      end

      client
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
      client_id = UUID.random.to_s
      plain_secret = ClientSecretService.generate
      hashed_secret = ClientSecretService.hash(plain_secret)
      now = Time.utc

      AuthorityDB.exec_query do |conn|
        conn.exec("BEGIN")
        begin
          conn.exec(
            "INSERT INTO oauth_clients (id, client_id, client_secret, name, description, logo, " \
            "redirect_uri, scopes, policy_url, tos_url, owner_id, is_confidential, created_at, updated_at) " \
            "VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11::uuid, $12, $13, $14)",
            UUID.random.to_s, client_id, hashed_secret, name, description, logo,
            redirect_uri, scopes, policy_url, tos_url, owner_id, is_confidential, now, now
          )
          conn.exec("COMMIT")
        rescue e
          conn.exec("ROLLBACK")
          raise e
        end
      end

      # Fetch the created client
      created_client = find_by_client_id(client_id)

      # Log audit trail
      if created_client && actor
        AuditService.log(
          actor: actor,
          action: AuditLog::Actions::CREATE,
          resource_type: AuditLog::ResourceTypes::CLIENT,
          resource_id: created_client.id,
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
      client_id = UUID.random.to_s
      plain_secret = ClientSecretService.generate
      hashed_secret = ClientSecretService.hash(plain_secret)
      now = Time.utc

      AuthorityDB.exec_query do |conn|
        conn.exec("BEGIN")
        begin
          conn.exec(
            "INSERT INTO oauth_clients (id, client_id, client_secret, name, description, logo, " \
            "redirect_uri, scopes, policy_url, tos_url, owner_id, is_confidential, created_at, updated_at) " \
            "VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11::uuid, $12, $13, $14)",
            UUID.random.to_s, client_id, hashed_secret, name, description, logo,
            redirect_uri, scopes, policy_url, tos_url, owner_id, is_confidential, now, now
          )
          conn.exec("COMMIT")
        rescue e
          conn.exec("ROLLBACK")
          raise e
        end
      end

      # Fetch the created client
      created_client = find_by_client_id(client_id)

      # Log audit trail
      if created_client && actor
        AuditService.log(
          actor: actor,
          action: AuditLog::Actions::CREATE,
          resource_type: AuditLog::ResourceTypes::CLIENT,
          resource_id: created_client.id,
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

      # Build update query dynamically
      updates = [] of String
      params = [] of String | Time | Bool | Nil
      param_idx = 1

      if name
        updates << "name = $#{param_idx}"
        params << name
        param_idx += 1
      end

      if description
        updates << "description = $#{param_idx}"
        params << description
        param_idx += 1
      end

      if logo
        updates << "logo = $#{param_idx}"
        params << logo
        param_idx += 1
      end

      if redirect_uri
        updates << "redirect_uri = $#{param_idx}"
        params << redirect_uri
        param_idx += 1
      end

      if scopes
        updates << "scopes = $#{param_idx}"
        params << scopes
        param_idx += 1
      end

      if policy_url
        updates << "policy_url = $#{param_idx}"
        params << policy_url
        param_idx += 1
      end

      if tos_url
        updates << "tos_url = $#{param_idx}"
        params << tos_url
        param_idx += 1
      end

      unless is_confidential.nil?
        updates << "is_confidential = $#{param_idx}"
        params << is_confidential
        param_idx += 1
      end

      updates << "updated_at = $#{param_idx}"
      params << Time.utc
      param_idx += 1

      params << id

      return Result.new(success: true, client: client) if updates.size == 1 # Only updated_at

      AuthorityDB.exec_query do |conn|
        conn.exec("BEGIN")
        begin
          conn.exec(
            "UPDATE oauth_clients SET #{updates.join(", ")} WHERE id = $#{param_idx}::uuid",
            args: params
          )
          conn.exec("COMMIT")
        rescue e
          conn.exec("ROLLBACK")
          raise e
        end
      end

      # Fetch updated client
      updated_client = get(id)

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
          resource_id: updated_client.id,
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

      AuthorityDB.exec_query do |conn|
        conn.exec("BEGIN")
        begin
          # Delete associated tokens
          conn.exec("DELETE FROM oauth_opaque_tokens WHERE client_id = $1", client_id_value)

          # Delete associated consents
          conn.exec("DELETE FROM oauth_consents WHERE client_id = $1", client_id_value)

          # Delete client
          conn.exec("DELETE FROM oauth_clients WHERE id = $1::uuid", id)

          conn.exec("COMMIT")
        rescue e
          conn.exec("ROLLBACK")
          raise e
        end
      end

      # Invalidate cache for this client
      ClientCacheService.invalidate(client_id_value)

      # Log audit trail
      AuditService.log(
        actor: actor,
        action: AuditLog::Actions::DELETE,
        resource_type: AuditLog::ResourceTypes::CLIENT,
        resource_id: client_uuid,
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

      AuthorityDB.exec_query do |conn|
        conn.exec("BEGIN")
        begin
          conn.exec(
            "UPDATE oauth_clients SET client_secret = $1, updated_at = $2 WHERE id = $3::uuid",
            hashed_secret, Time.utc, id
          )
          conn.exec("COMMIT")
        rescue e
          conn.exec("ROLLBACK")
          raise e
        end
      end

      updated_client = get(id)

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
          resource_id: updated_client.id,
          resource_name: updated_client.name,
          ip_address: ip_address
        )
      end

      {Result.new(success: true, client: updated_client), plain_secret}
    rescue e
      {Result.new(success: false, error: e.message, error_code: "regenerate_failed"), nil}
    end

    # Find client by client_id (UUID string used in OAuth flows)
    private def self.find_by_client_id(client_id : String) : Client?
      client = nil

      AuthorityDB.exec_query do |conn|
        conn.query_one?(
          "SELECT id, client_id, client_secret, name, description, logo, redirect_uri, scopes, " \
          "policy_url, tos_url, owner_id, is_confidential, created_at, updated_at " \
          "FROM oauth_clients WHERE client_id = $1::uuid",
          client_id
        ) do |rs|
          c = Client.new
          c.id = rs.read(UUID)
          c.client_id = rs.read(UUID).to_s
          c.client_secret = rs.read(String)
          c.name = rs.read(String)
          c.description = rs.read(String?)
          c.logo = rs.read(String?) || ""
          c.redirect_uri = rs.read(String)
          c.scopes = rs.read(String?) || ""
          c.policy_url = rs.read(String?)
          c.tos_url = rs.read(String?)
          c.owner_id = rs.read(UUID?)
          c.is_confidential = rs.read(Bool?) || true
          c.created_at = rs.read(Time?)
          c.updated_at = rs.read(Time?)
          client = c
        end
      end

      client
    end
  end
end
