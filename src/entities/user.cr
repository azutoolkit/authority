module Authority
  class User
    include Clear::Model

    self.table = "oauth_owners"

    primary_key :id, type: :uuid
    column username : String
    column email : String
    column first_name : String
    column last_name : String
    column email_verified : Bool = false
    column scope : String
    column encrypted_password : Crypto::Bcrypt::Password
    timestamps

    def password=(plain_text : String)
      self.encrypted_password = Crypto::Bcrypt::Password.create(plain_text)
    end

    def verify?(password : String)
      self.encrypted_password.verify(password)
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
  end
end
