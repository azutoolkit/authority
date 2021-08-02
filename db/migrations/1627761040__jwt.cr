class CreateJwt
  include Clear::Migration

  def change(direction)
    direction.up do
      create_table :jwts do |t|
        t.column :client_id, "varchar(80)", null: false
        t.column :subject, "varchar(80)", null: false
        t.column :publick_key, "varchar(2000)", null: false

        t.timestamps
      end
    end

    direction.down do
      execute "DROP TABLE IF EXISTS jwts;"
    end
  end
end
