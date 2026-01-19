# OAuth Clients Table Migration
# Stores registered OAuth client applications
class CreateClients < CQL::Migration(1627760477)
  def up
    schema.table :oauth_clients do
      primary :id, UUID
      column :client_id, UUID, index: true, unique: true
      text :name, null: false, index: true, unique: true
      text :description, null: true
      text :logo, null: false
      text :client_secret, null: false
      text :redirect_uri, null: false
      text :scopes, null: false
      timestamps
    end
    schema.oauth_clients.create!
  end

  def down
    schema.oauth_clients.drop!
  end
end
