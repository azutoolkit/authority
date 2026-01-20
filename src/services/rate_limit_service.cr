# Rate Limiting Service
# Implements sliding window rate limiting to prevent brute force attacks.
# Uses in-memory storage suitable for single-instance deployments.
module Authority
  module RateLimitService
    # Define rate limit configurations per operation type
    LIMITS = {
      signin:    {limit: 5, window: 60},  # 5 attempts per minute
      token:     {limit: 20, window: 60}, # 20 requests per minute
      authorize: {limit: 30, window: 60}, # 30 requests per minute
      register:  {limit: 10, window: 60}, # 10 registrations per minute
      device:    {limit: 10, window: 60}, # 10 device code requests per minute
    }

    # Stores request timestamps per key
    @@buckets = {} of String => Array(Int64)
    @@mutex = Mutex.new

    # Check if a request is allowed and record it if so.
    #
    # @param key [String] Unique identifier (e.g., IP address, client_id)
    # @param operation [Symbol] Type of operation being rate limited
    # @return [Bool] True if the request is allowed
    def self.allowed?(key : String, operation : Symbol) : Bool
      config = LIMITS[operation]? || {limit: 10, window: 60}
      limit = config[:limit]
      window = config[:window]

      bucket_key = "#{operation}:#{key}"
      now = Time.utc.to_unix

      @@mutex.synchronize do
        requests = @@buckets[bucket_key]? || [] of Int64

        # Remove expired timestamps
        cutoff = now - window
        requests = requests.select { |timestamp| timestamp > cutoff }

        if requests.size < limit
          requests << now
          @@buckets[bucket_key] = requests
          true
        else
          @@buckets[bucket_key] = requests
          false
        end
      end
    end

    # Get the number of remaining requests in the current window.
    #
    # @param key [String] Unique identifier
    # @param operation [Symbol] Type of operation
    # @return [Int32] Number of remaining requests allowed
    def self.remaining(key : String, operation : Symbol) : Int32
      config = LIMITS[operation]? || {limit: 10, window: 60}
      limit = config[:limit]
      window = config[:window]

      bucket_key = "#{operation}:#{key}"
      now = Time.utc.to_unix

      @@mutex.synchronize do
        requests = @@buckets[bucket_key]? || [] of Int64
        cutoff = now - window
        active_requests = requests.count { |timestamp| timestamp > cutoff }
        Math.max(0, limit - active_requests)
      end
    end

    # Get seconds until the rate limit window resets (if currently limited).
    #
    # @param key [String] Unique identifier
    # @param operation [Symbol] Type of operation
    # @return [Int32?] Seconds until reset, or nil if not rate limited
    def self.retry_after(key : String, operation : Symbol) : Int32?
      config = LIMITS[operation]? || {limit: 10, window: 60}
      limit = config[:limit]
      window = config[:window]

      bucket_key = "#{operation}:#{key}"
      now = Time.utc.to_unix

      @@mutex.synchronize do
        requests = @@buckets[bucket_key]? || [] of Int64
        cutoff = now - window
        active_requests = requests.select { |timestamp| timestamp > cutoff }

        if active_requests.size >= limit
          # Find when the oldest request will expire
          oldest = active_requests.min
          seconds_until_reset = (oldest + window - now).to_i32
          Math.max(1, seconds_until_reset)
        else
          nil
        end
      end
    end

    # Clear all rate limit data (for testing)
    def self.clear_all : Nil
      @@mutex.synchronize do
        @@buckets.clear
      end
    end

    # Clear rate limit data for a specific key (for admin purposes)
    def self.clear(key : String, operation : Symbol) : Nil
      bucket_key = "#{operation}:#{key}"
      @@mutex.synchronize do
        @@buckets.delete(bucket_key)
      end
    end
  end
end
