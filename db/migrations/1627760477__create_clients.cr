class CreateClients
  include Clear::Migration

  def change(dir)
    dir.up do
      create_table :clients, id: :uuid do |t|
        t.column :client_id, "uuid", index: true, unique: true, default: "uuid_generate_v4()"
        t.column :name, "varchar(120)", null: false, index: true, unique: true
        t.column :description, "varchar(2000)"
        t.column :logo, "varchar(120)", null: false
        t.column :client_secret, "varchar(80)", null: false
        t.column :redirect_uri, "varchar(2000)", null: false
        t.column :scopes, "varchar(4000)", null: false

        t.timestamps
      end
    end

    dir.down do
      execute "DROP TABLE IF EXISTS ;"
    end
  end
end
