module Authority
  class User
    include CQL::ActiveRecord::Model(String)
    db_context AuthorityDB, :oauth_owners

    property id : String?
    property username : String = ""
    property email : String = ""
    property first_name : String = ""
    property last_name : String = ""
    property email_verified : Bool = false
    property scope : String = ""
    property encrypted_password : String = ""
    property created_at : Time?
    property updated_at : Time?

    # Initialize with default values for new records
    def initialize
    end

    # Override create! to handle UUID primary keys
    def create!
      validate!
      @id ||= UUID.random.to_s
      attrs = attributes
      CQL::Insert
        .new(User.schema)
        .into(User.table)
        .values(attrs)
        .commit
      self
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
