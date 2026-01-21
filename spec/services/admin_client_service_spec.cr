require "../spec_helper"

# Helper to create admin user for tests
def create_test_admin_user : Authority::User
  admin = Authority::User.new
  admin.username = "admin_user_#{Random.rand(10000)}"
  admin.email = "admin#{Random.rand(10000)}@example.com"
  admin.first_name = "Admin"
  admin.last_name = "User"
  admin.password = "admin_password"
  admin.scope = "authority:admin"
  admin.save!
  admin
end

# Helper to create test client via direct SQL (matches existing pattern)
def create_test_client(name : String = "Test Client") : Authority::Client
  id = UUID.random.to_s
  client_id = UUID.random.to_s
  secret = "test_secret_#{Random.rand(10000)}"
  redirect_uri = "https://example#{Random.rand(10000)}.com/callback"
  scopes = "read"
  now = Time.utc

  AuthorityDB.exec_query do |conn|
    conn.exec(
      "INSERT INTO oauth_clients (id, client_id, client_secret, redirect_uri, name, description, logo, scopes, created_at, updated_at) " \
      "VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)",
      id, client_id, secret, redirect_uri, name, "Test description", "", scopes, now, now
    )
  end

  client = Authority::Client.new
  client.id = UUID.new(id)
  client.client_id = client_id
  client.client_secret = secret
  client.redirect_uri = redirect_uri
  client.name = name
  client.scopes = scopes
  client
end

describe Authority::AdminClientService do
  Spec.before_each do
    AuthorityDB.exec_query { |conn| conn.exec("TRUNCATE TABLE oauth_clients CASCADE") }
    AuthorityDB.exec_query { |conn| conn.exec("TRUNCATE TABLE oauth_owners CASCADE") }
  end

  describe ".list" do
    it "returns empty array when no clients exist" do
      result = Authority::AdminClientService.list
      result.should be_a Array(Authority::Client)
      result.size.should eq 0
    end

    it "returns all clients with pagination" do
      # Create test clients
      3.times do |i|
        create_test_client("Test Client #{i}")
      end

      result = Authority::AdminClientService.list(page: 1, per_page: 2)
      result.size.should eq 2

      result2 = Authority::AdminClientService.list(page: 2, per_page: 2)
      result2.size.should eq 1
    end
  end

  describe ".get" do
    it "returns client by ID" do
      client = create_test_client("Get Test Client")

      result = Authority::AdminClientService.get(client.id.to_s)
      result.should_not be_nil
      if found_client = result
        found_client.name.should eq "Get Test Client"
      end
    end

    it "returns nil for non-existent client" do
      result = Authority::AdminClientService.get(UUID.random.to_s)
      result.should be_nil
    end
  end

  describe ".create" do
    it "creates a new client with hashed secret" do
      admin = create_test_admin_user
      result = Authority::AdminClientService.create(
        name: "New Test Client",
        redirect_uri: "https://newclient.com/callback",
        description: "A test client",
        scopes: "read write",
        actor: admin
      )

      result.success?.should be_true
      result.client.should_not be_nil

      if client = result.client
        client.name.should eq "New Test Client"
        client.redirect_uri.should eq "https://newclient.com/callback"
        client.client_id.should_not be_empty
        client.client_secret.should start_with "$2a$" # bcrypt hash
      end
    end

    it "returns plain secret on creation" do
      result, plain_secret = Authority::AdminClientService.create_with_secret(
        name: "Secret Test Client",
        redirect_uri: "https://secretclient.com/callback",
        scopes: "read"
      )

      result.success?.should be_true
      plain_secret.should_not be_nil

      if secret = plain_secret
        secret.size.should be >= 32

        # Verify the plain secret matches the hashed one
        if client = result.client
          Authority::ClientSecretService.verify(secret, client.client_secret).should be_true
        end
      end
    end

    it "fails with duplicate name" do
      create_test_client("Existing Client")

      result = Authority::AdminClientService.create(
        name: "Existing Client",
        redirect_uri: "https://newclient.com/callback",
        scopes: "read"
      )

      result.success?.should be_false
      result.error_code.should eq "create_failed"
    end
  end

  describe ".update" do
    it "updates client metadata" do
      client = create_test_client("Original Name")

      admin = create_test_admin_user
      result = Authority::AdminClientService.update(
        id: client.id.to_s,
        name: "Updated Name",
        description: "New description",
        actor: admin
      )

      result.success?.should be_true
      if updated = result.client
        updated.name.should eq "Updated Name"
        updated.description.should eq "New description"
      end
    end

    it "returns not_found for non-existent client" do
      result = Authority::AdminClientService.update(
        id: UUID.random.to_s,
        name: "Updated Name"
      )

      result.success?.should be_false
      result.error_code.should eq "not_found"
    end
  end

  describe ".delete" do
    it "deletes client and associated data" do
      client = create_test_client("Delete Me")

      admin = create_test_admin_user
      result = Authority::AdminClientService.delete(
        id: client.id.to_s,
        actor: admin
      )

      result.success?.should be_true

      # Verify client is deleted
      Authority::AdminClientService.get(client.id.to_s).should be_nil
    end

    it "returns not_found for non-existent client" do
      admin = create_test_admin_user
      result = Authority::AdminClientService.delete(
        id: UUID.random.to_s,
        actor: admin
      )

      result.success?.should be_false
      result.error_code.should eq "not_found"
    end
  end

  describe ".regenerate_secret" do
    it "generates new secret and invalidates old one" do
      # Create client with known secret
      id = UUID.random.to_s
      client_id = UUID.random.to_s
      old_secret_hash = Authority::ClientSecretService.hash("old_secret")
      now = Time.utc

      AuthorityDB.exec_query do |conn|
        conn.exec(
          "INSERT INTO oauth_clients (id, client_id, client_secret, redirect_uri, name, description, logo, scopes, created_at, updated_at) " \
          "VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)",
          id, client_id, old_secret_hash, "https://regen.com/callback", "Regen Secret", "", "", "read", now, now
        )
      end

      admin = create_test_admin_user
      result, new_secret = Authority::AdminClientService.regenerate_secret(
        id: id,
        actor: admin
      )

      result.success?.should be_true
      new_secret.should_not be_nil

      # Verify old secret no longer works
      if updated_client = Authority::AdminClientService.get(id)
        Authority::ClientSecretService.verify("old_secret", updated_client.client_secret).should be_false

        # Verify new secret works
        if secret = new_secret
          Authority::ClientSecretService.verify(secret, updated_client.client_secret).should be_true
        end
      end
    end
  end
end
