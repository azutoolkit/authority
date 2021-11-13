# Model Docs - https://clear.gitbook.io/project/model/column-types
module Authority
  class OwnerEntity
    include Clear::Model

    self.table = "owners"

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
