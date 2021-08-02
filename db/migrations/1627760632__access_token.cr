class CreateAccessToken
  include Clear::Migration

  def change(direction)
    direction.up do
      create_table :access_tokens do |t|
        t.column :access_token, "varchar(40)", null: false, index: true, unique: true
        t.column :client_id, "varchar(80)", null: false
        t.column :user_id, "varchar(80)", null: false
        t.column :expires, "timestamp", null: false
        t.column :scope, "varchar(4000)", null: false

        t.timestamps
      end
    end

    direction.down do
      execute "DROP TABLE IF EXISTS access_tokens;"
    end
  end
end
