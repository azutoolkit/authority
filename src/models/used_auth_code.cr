# Used Authorization Code Model
# Tracks authorization codes that have been used to prevent replay attacks
module Authority
  class UsedAuthCode
    include CQL::ActiveRecord::Model(String)
    db_context AuthorityDB, :oauth_used_auth_codes

    property code_hash : String = ""
    property client_id : String = ""
    property used_at : Time?

    def initialize
    end

    # Check if a code hash has been used
    def self.used?(code_hash : String) : Bool
      exists?(code_hash: code_hash)
    end

    # Mark a code as used, returns true if successful
    def self.mark_used!(code_hash : String, client_id : String) : Bool
      return true if used?(code_hash)

      auth_code = UsedAuthCode.new
      auth_code.code_hash = code_hash
      auth_code.client_id = client_id
      auth_code.used_at = Time.utc
      auth_code.save!
      true
    rescue
      false
    end

    # Try to use a code atomically, detecting reuse
    def self.try_use(code_hash : String, client_id : String) : NamedTuple(success: Bool, reuse_detected: Bool)
      if used?(code_hash)
        return {success: false, reuse_detected: true}
      end

      auth_code = UsedAuthCode.new
      auth_code.code_hash = code_hash
      auth_code.client_id = client_id
      auth_code.used_at = Time.utc
      auth_code.save!
      {success: true, reuse_detected: false}
    rescue
      # Could be race condition - check again
      {success: false, reuse_detected: used?(code_hash)}
    end

    # Cleanup old used codes, returns count of deleted rows
    def self.cleanup_expired!(max_age : Time::Span = 10.minutes) : Int64
      cutoff = Time.utc - max_age
      # Fetch and delete in memory to avoid complex DSL issues
      codes = UsedAuthCode.query.all.select do |code|
        if used_at = code.used_at
          used_at < cutoff
        else
          false
        end
      end
      count = codes.size.to_i64
      codes.each(&.delete!)
      count
    end
  end
end
