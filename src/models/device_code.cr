module Authority
  enum Verification
    Allowed
    Denied
    Pending
  end

  class DeviceCode
    include CQL::ActiveRecord::Model(UUID)
    db_context AuthorityDB, :oauth_device_codes

    property client_id : String = ""
    property client_name : String = ""
    property user_code : String = ""
    property verification : String = "pending"
    property verification_uri : String = ""
    property expires_at : Time = Time.utc
    property created_at : Time?
    property updated_at : Time?

    before_save :set_defaults

    def initialize
    end

    private def set_defaults
      @user_code = Random::Secure.hex(3).upcase if @user_code.empty?
      @expires_at = 5.minutes.from_now if @expires_at == Time.utc
      true
    end

    def verification_status : Verification
      case verification.downcase
      when "allowed" then Verification::Allowed
      when "denied"  then Verification::Denied
      else                Verification::Pending
      end
    end

    def verification_message : String?
      case verification_status
      when Verification::Pending then "authorization_pending"
      when Verification::Denied  then "access_denied"
      else                            nil
      end
    end

    def expired? : Bool
      Time.utc > expires_at
    end

    # Device code error record
    record DeviceError, reason : String

    # Returns validation errors for device code token exchange
    def device_errors : Array(DeviceError)
      errs = [] of DeviceError
      errs << DeviceError.new(verification_message.to_s) if verification_message
      errs << DeviceError.new("expired_token") if expired?
      errs
    end

    # Check if device code is valid for token exchange
    def valid_for_token? : Bool
      verification_status == Verification::Allowed && !expired?
    end
  end
end
