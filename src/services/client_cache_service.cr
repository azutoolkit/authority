# Client Cache Service
# Provides in-memory caching for OAuth clients to improve token validation performance.
# Features:
# - TTL-based expiration (5 minutes default)
# - Background warmup on startup
# - Automatic invalidation on update/delete
module Authority
  module ClientCacheService
    extend self

    # Cache entry struct with expiration tracking
    struct CacheEntry
      getter client : Client
      getter expires_at : Time

      def initialize(@client : Client, ttl : Time::Span = 5.minutes)
        @expires_at = Time.utc + ttl
      end

      def expired? : Bool
        Time.utc > @expires_at
      end
    end

    # In-memory cache storage
    @@cache = {} of String => CacheEntry
    @@mutex = Mutex.new
    @@ttl : Time::Span = 5.minutes
    @@warmed_up = false

    # Get a client by client_id from cache or database
    def get(client_id : String) : Client?
      @@mutex.synchronize do
        if entry = @@cache[client_id]?
          if entry.expired?
            @@cache.delete(client_id)
          else
            return entry.client
          end
        end
      end

      # Cache miss - fetch from database
      client = fetch_from_db(client_id)
      if client
        set(client_id, client)
      end
      client
    end

    # Store a client in the cache
    def set(client_id : String, client : Client) : Nil
      @@mutex.synchronize do
        @@cache[client_id] = CacheEntry.new(client, @@ttl)
      end
    end

    # Invalidate a specific client in the cache
    def invalidate(client_id : String) : Nil
      @@mutex.synchronize do
        @@cache.delete(client_id)
      end
    end

    # Invalidate all entries in the cache
    def invalidate_all : Nil
      @@mutex.synchronize do
        @@cache.clear
      end
    end

    # Warm up the cache by loading all clients
    def warm : Nil
      Log.info { "ClientCacheService: Starting cache warmup..." }
      count = 0

      Client.all.each do |client|
        set(client.client_id, client)
        count += 1
      end

      @@warmed_up = true
      Log.info { "ClientCacheService: Cache warmup complete. Loaded #{count} clients." }
    rescue ex
      Log.error { "ClientCacheService: Cache warmup failed: #{ex.message}" }
    end

    # Start background warmup in a fiber
    def warm_async : Nil
      spawn do
        warm
      end
    end

    # Remove expired entries from the cache
    def cleanup : Int32
      removed = 0
      @@mutex.synchronize do
        expired_keys = @@cache.select { |_, entry| entry.expired? }.keys
        expired_keys.each do |key|
          @@cache.delete(key)
          removed += 1
        end
      end
      removed
    end

    # Get cache statistics
    def stats : NamedTuple(size: Int32, warmed_up: Bool, ttl_seconds: Int64)
      size = @@mutex.synchronize { @@cache.size }
      {size: size, warmed_up: @@warmed_up, ttl_seconds: @@ttl.total_seconds.to_i64}
    end

    # Check if cache has been warmed up
    def warmed_up? : Bool
      @@warmed_up
    end

    # Set the TTL for cache entries (for testing)
    def ttl=(ttl : Time::Span) : Nil
      @@ttl = ttl
    end

    # Reset the cache (for testing)
    def reset : Nil
      @@mutex.synchronize do
        @@cache.clear
      end
      @@warmed_up = false
    end

    # Fetch client from database by client_id
    private def fetch_from_db(client_id : String) : Client?
      Client.find_by(client_id: client_id)
    rescue
      nil
    end
  end
end
