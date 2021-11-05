# Model Docs - https://clear.gitbook.io/project/model/column-types
module Authority
  class User
    include Clear::Model

    primary_key
    column username : String
    column password : String
    column email : String
    column encrypted_password : Crypto::Bcrypt::Password
    timestamps

    def encrypted_password=(plain_text : String)
      self.encrypted_password = Crypto::Bcrypt::Password.create(plain_text)
    end

    def verify?(password : String)
      self.encrypted_password.verify(password)
    end

    def id_token
      {
        "user_id"    => id.to_s,
        "first_name" => first_name,
        "last_name"  => last_name,
        "email"      => email,
        "created_at" => created_at.to_s,
        "updated_at" => updated_at.to_s,
      }
    end
  end
end
