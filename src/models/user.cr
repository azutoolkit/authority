module Authority
  @[Crinja::Attributes(expose: [id, username, email, first_name, last_name, role, email_verified, locked_at, last_login_at, created_at, updated_at, locked?])]
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
    property created_at : Time?
    property updated_at : Time?

    def initialize
    end

    # Check if user account is locked
    def locked? : Bool
      !locked_at.nil?
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
