module Authority
  @[Crinja::Attributes(expose: [id_str, username, email, first_name, last_name, role, scope, scopes_list, email_verified, locked_at, lock_reason, failed_login_attempts, last_login_at, last_login_ip, created_at, updated_at, locked, password_changed_at, mfa_enabled])]
  class User
    include CQL::ActiveRecord::Model(UUID)
    include Crinja::Object::Auto
    db_context AuthorityDB, :oauth_owners

    property username : String = ""
    property email : String = ""
    property first_name : String = ""
    property last_name : String = ""
    property email_verified : Bool = false
    property scope : String = ""
    property encrypted_password : String = ""
    property role : String = "user"
    property locked_at : Time?
    property lock_reason : String?
    property failed_login_attempts : Int32 = 0
    property last_login_at : Time?
    property last_login_ip : String?
    property password_changed_at : Time?
    property password_history : String?  # JSON array of previous bcrypt hashes
    property mfa_enabled : Bool = false
    property totp_secret : String?
    property backup_codes : String?      # JSON array of backup codes
    property created_at : Time?
    property updated_at : Time?

    def initialize
    end

    # Returns UUID as string for template rendering
    def id_str : String
      id.to_s
    end

    # Check if user account is locked
    def locked? : Bool
      !locked_at.nil?
    end

    # Alias method for Crinja template access (without ? suffix)
    def locked : Bool
      locked?
    end

    # Returns scopes as an array for template iteration
    def scopes_list : Array(String)
      scope.split(' ').reject(&.empty?)
    end

    def password=(plain_text : String)
      @encrypted_password = Crypto::Bcrypt::Password.create(plain_text).to_s
    end

    def verify?(password : String) : Bool
      Crypto::Bcrypt::Password.new(encrypted_password).verify(password)
    end

    def claims
      {
        "sub"            => id.to_s,
        "first_name"     => first_name,
        "last_name"      => last_name,
        "email"          => email,
        "email_verified" => email_verified.to_s,
        "scope"          => scope,
        "created_at"     => created_at.to_s,
        "updated_at"     => updated_at.to_s,
        "iat"            => Time.utc.to_unix,
        "exp"            => 1.hour.from_now.to_unix,
      }
    end

    def id_token
      {
        "user_id"        => id.to_s,
        "first_name"     => first_name,
        "last_name"      => last_name,
        "email"          => email,
        "scope"          => scope,
        "email_verified" => email_verified.to_s,
        "created_at"     => created_at.to_s,
        "updated_at"     => updated_at.to_s,
        "iat"            => Time.utc.to_unix,
        "exp"            => 1.hour.from_now.to_unix,
      }
    end
  end
end
