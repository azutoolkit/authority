class Create
  include Clear::Migration

  def change(direction)
    direction.up do
      create_table :clients do |t|
        t.column :client_id, "varchar(80)", null: false, index: true, unique: true
        t.column :client_secret, "varchar(80)", null: false
        t.column :redirect_uri, "varchar(2000)", null: false
        t.column :grant_types, "varchar(80)", null: false
        t.column :scope, "varchar(4000)", null: false

        t.timestamps
      end
    end

    direction.down do
      execute "DROP TABLE IF EXISTS ;"
    end
  end
end
