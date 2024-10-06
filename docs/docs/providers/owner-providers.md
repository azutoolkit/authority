# Owner Providers

### Overview

Owner providers in the Authority system represent the resource owners—typically the users who own the data or resources being accessed. They play a crucial role in controlling access to their resources.

### Configuring Owner Providers

To configure an owner provider, you need to establish ownership models in your application. This usually involves mapping user records to resources that they own.

```crystal
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

```

#### Example Configuration

In your database schema, make sure that resources have an `owner_id` field that corresponds to the user who owns the resource.

```sql
CREATE TABLE resources (
    id SERIAL PRIMARY KEY,
    owner_id INTEGER REFERENCES users(id)
);
```

### Using Owner Providers

Once the ownership structure is in place, you can enforce access control rules by checking whether the currently authenticated user is the owner of the resource they are trying to access.

Example in Crystal:

```crystal
# Assuming `current_user` is the authenticated user and `resource` is the requested resource.
module Authority
  class OwnerProvider
    include Authly::AuthorizableOwner

    def authorized?(username : String, password : String) : Bool
      OwnerRepo.authenticate? username, password
    end

    def id_token(user_id : String) : Hash(String, Int64 | String)
      OwnerRepo.id_token user_id
    end
  end
end
```

Owner providers help implement fine-grained access control mechanisms, ensuring that users can only access the resources they own.
