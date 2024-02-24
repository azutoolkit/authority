module Authority
  Clear.enum Verification, "allowed", "denied", "pending"

  class DeviceCode
    include Clear::Model

    self.table = "oauth_device_codes"

    primary_key :id, type: :uuid

    column client_id : String
    column client_name : String
    column user_code : String = "#{Random.hex(3)}".upcase
    column verification : Authority::Verification = Verification::Pending
    column verification_uri : String
    column expires_at : Time = 5.munites.from_now
    column created_at : Time = Time.utc

    def validate
      if persisted?
        add_error "verification", verification_message.to_s unless verification_message.nil?
      end
      add_error "expires_at", "expired_token" if expired?
    end

    def verification_message
      case verification
      when Verification::Pending then "authorization_pending"
      when Verification::Denied  then "access_denied"
      end
    end

    def expired?
      Time.utc > expires_at
    end
  end
end
