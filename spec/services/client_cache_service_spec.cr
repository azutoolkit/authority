require "../spec_helper"

# Helper module for ClientCacheService tests
module ClientCacheTestHelpers
  def self.create_test_client : Authority::Client
    client_id = UUID.random.to_s
    secret = Authority::ClientSecretService.generate
    hashed_secret = Authority::ClientSecretService.hash(secret)
    now = Time.utc
    id = UUID.random.to_s

    AuthorityDB.exec_query do |conn|
      conn.exec(
        "INSERT INTO oauth_clients (id, client_id, client_secret, name, description, logo, " \
        "redirect_uri, scopes, created_at, updated_at) " \
        "VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)",
        id, client_id, hashed_secret, "Test Client #{client_id[0, 8]}", "Test Description",
        "", "https://example.com/callback", "read write", now, now
      )
    end

    # Fetch and return the client
    client = Authority::Client.new
    AuthorityDB.exec_query do |conn|
      conn.query_one?(
        "SELECT id, client_id, client_secret, name, description, logo, redirect_uri, scopes, " \
        "policy_url, tos_url, owner_id, is_confidential, created_at, updated_at " \
        "FROM oauth_clients WHERE client_id = $1::uuid",
        client_id
      ) do |rs|
        client.id = rs.read(UUID)
        client.client_id = rs.read(UUID).to_s
        client.client_secret = rs.read(String)
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
      end
    end

    client
  end

  def self.delete_test_client(client_id : String)
    AuthorityDB.exec_query do |conn|
      conn.exec("DELETE FROM oauth_clients WHERE client_id = $1::uuid", client_id)
    end
  end
end

describe Authority::ClientCacheService do
  before_each do
    AuthorityDB.exec_query { |conn| conn.exec("TRUNCATE TABLE oauth_clients CASCADE") }
    Authority::ClientCacheService.reset
  end

  describe ".get" do
    it "returns nil for non-existent client" do
      result = Authority::ClientCacheService.get(UUID.random.to_s)
      result.should be_nil
    end

    it "fetches client from database on cache miss" do
      client = ClientCacheTestHelpers.create_test_client

      # First call should fetch from DB
      cached = Authority::ClientCacheService.get(client.client_id)
      cached.should_not be_nil
      cached.not_nil!.name.should eq(client.name)

      ClientCacheTestHelpers.delete_test_client(client.client_id)
    end

    it "returns cached client on cache hit" do
      client = ClientCacheTestHelpers.create_test_client

      # First call - cache miss, fetches from DB
      Authority::ClientCacheService.get(client.client_id)

      # Delete from DB
      ClientCacheTestHelpers.delete_test_client(client.client_id)

      # Second call - should still return cached client
      cached = Authority::ClientCacheService.get(client.client_id)
      cached.should_not be_nil
      cached.not_nil!.name.should eq(client.name)
    end

    it "removes expired entries and refetches" do
      client = ClientCacheTestHelpers.create_test_client

      # Set very short TTL
      Authority::ClientCacheService.set_ttl(1.millisecond)

      # Cache the client
      Authority::ClientCacheService.get(client.client_id)

      # Wait for expiration
      sleep 10.milliseconds

      # Should be expired and refetch
      cached = Authority::ClientCacheService.get(client.client_id)
      cached.should_not be_nil

      ClientCacheTestHelpers.delete_test_client(client.client_id)

      # Reset TTL
      Authority::ClientCacheService.set_ttl(5.minutes)
    end
  end

  describe ".set" do
    it "stores a client in the cache" do
      client = ClientCacheTestHelpers.create_test_client

      Authority::ClientCacheService.set(client.client_id, client)

      stats = Authority::ClientCacheService.stats
      stats[:size].should eq(1)

      ClientCacheTestHelpers.delete_test_client(client.client_id)
    end
  end

  describe ".invalidate" do
    it "removes a specific client from the cache" do
      client = ClientCacheTestHelpers.create_test_client

      Authority::ClientCacheService.set(client.client_id, client)
      Authority::ClientCacheService.stats[:size].should eq(1)

      Authority::ClientCacheService.invalidate(client.client_id)
      Authority::ClientCacheService.stats[:size].should eq(0)

      ClientCacheTestHelpers.delete_test_client(client.client_id)
    end
  end

  describe ".invalidate_all" do
    it "clears all entries from the cache" do
      client1 = ClientCacheTestHelpers.create_test_client
      client2 = ClientCacheTestHelpers.create_test_client

      Authority::ClientCacheService.set(client1.client_id, client1)
      Authority::ClientCacheService.set(client2.client_id, client2)
      Authority::ClientCacheService.stats[:size].should eq(2)

      Authority::ClientCacheService.invalidate_all
      Authority::ClientCacheService.stats[:size].should eq(0)

      ClientCacheTestHelpers.delete_test_client(client1.client_id)
      ClientCacheTestHelpers.delete_test_client(client2.client_id)
    end
  end

  describe ".warm" do
    it "loads all clients into cache" do
      client1 = ClientCacheTestHelpers.create_test_client
      client2 = ClientCacheTestHelpers.create_test_client

      Authority::ClientCacheService.warmed_up?.should be_false

      Authority::ClientCacheService.warm

      Authority::ClientCacheService.warmed_up?.should be_true
      Authority::ClientCacheService.stats[:size].should be >= 2

      ClientCacheTestHelpers.delete_test_client(client1.client_id)
      ClientCacheTestHelpers.delete_test_client(client2.client_id)
    end
  end

  describe ".cleanup" do
    it "removes expired entries" do
      client = ClientCacheTestHelpers.create_test_client

      # Set very short TTL
      Authority::ClientCacheService.set_ttl(1.millisecond)

      Authority::ClientCacheService.set(client.client_id, client)
      Authority::ClientCacheService.stats[:size].should eq(1)

      # Wait for expiration
      sleep 10.milliseconds

      removed = Authority::ClientCacheService.cleanup
      removed.should eq(1)
      Authority::ClientCacheService.stats[:size].should eq(0)

      ClientCacheTestHelpers.delete_test_client(client.client_id)

      # Reset TTL
      Authority::ClientCacheService.set_ttl(5.minutes)
    end
  end

  describe ".stats" do
    it "returns cache statistics" do
      stats = Authority::ClientCacheService.stats
      stats[:size].should eq(0)
      stats[:warmed_up].should be_false
      stats[:ttl_seconds].should eq(300)
    end
  end

  describe ".reset" do
    it "clears cache and resets warmed_up flag" do
      client = ClientCacheTestHelpers.create_test_client

      Authority::ClientCacheService.set(client.client_id, client)
      Authority::ClientCacheService.warm

      Authority::ClientCacheService.stats[:size].should be > 0
      Authority::ClientCacheService.warmed_up?.should be_true

      Authority::ClientCacheService.reset

      Authority::ClientCacheService.stats[:size].should eq(0)
      Authority::ClientCacheService.warmed_up?.should be_false

      ClientCacheTestHelpers.delete_test_client(client.client_id)
    end
  end
end
