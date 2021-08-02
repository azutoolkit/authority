class CreateRefreshToken
  include Clear::Migration

  def change(direction)
    direction.up do
      create_table :refresh_tokens do |t|
        t.column :refresh_token, "varchar(80)", null: false, index: true, unique: true
        t.column :client_id, "varchar(80)", null: false
        t.column :user_id, "varchar(80)", null: false
        t.column :expires, "timestamp", null: false
        t.column :scope, "varchar(4000)", null: false

        t.timestamps
      end
    end

    direction.down do
      execute "DROP TABLE IF EXISTS refresh_tokens;"
    end
  end
end
