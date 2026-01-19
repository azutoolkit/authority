# OAuth Resource Owners (Users) Table Migration
# Stores user accounts for OAuth authentication
class CreateOwners < CQL::Migration(1627760814)
  def up
    schema.table :oauth_owners do
      primary :id, UUID
      text :username, null: false, index: true, unique: true
      text :encrypted_password, null: false
      text :first_name, null: false
      text :last_name, null: false
      text :email, null: false
      boolean :email_verified, null: false, default: false
      text :scope, null: false
      timestamps
    end
    schema.oauth_owners.create!
  end

  def down
    schema.oauth_owners.drop!
  end
end
