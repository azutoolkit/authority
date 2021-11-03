class CreateClients
  include Clear::Migration

  def change(direction)
    direction.up do
      create_table :clients do |t|
        t.column :client_id, "uuid", null: false, index: true, unique: true
        t.column :name, "varchar(120)", null: false, index: true, unique: true
        t.column :description, "varchar(2000)"
        t.column :client_secret, "varchar(80)", null: false
        t.column :redirect_uri, "varchar(2000)", null: false
        t.column :scopes, "varchar(4000)", null: false

        t.timestamps
      end
    end

    direction.down do
      execute "DROP TABLE IF EXISTS ;"
    end
  end
end
