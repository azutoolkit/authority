class CreateAuthorizationCode
  include Clear::Migration

  def change(direction)
    direction.up do
      create_table :authorization_codes do |t|
        t.column :authorization_code, "varchar(40)", null: false, index: true, unique: true
        t.column :client_id, "varchar(80)", null: false
        t.column :user_id, "varchar(80)", null: false
        t.column :redirect_uri, "varchar(2000)", null: false
        t.column :expires, "timestamp", null: false
        t.column :scope, "varchar(4000)", null: false
        t.column :id_token, "varchar(1000)", null: false
        t.column :code_challenge, "varchar(128)", null: false
        t.column :code_challenge_method, "varchar(10)", null: false

        t.timestamps
      end
    end

    direction.down do
      execute "DROP TABLE IF EXISTS authorization_codes;"
    end
  end
end
