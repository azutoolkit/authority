class CreateUser
  include Clear::Migration

  def change(direction)
    direction.up do
      create_table :users, id: :uuid do |t|
        t.column :username, "varchar(80)", null: false, index: true, unique: true
        t.column :encrypted_password, "varchar(80)", null: false
        t.column :first_name, "varchar(80)", null: false
        t.column :last_name, "varchar(80)", null: false
        t.column :email, "varchar(80)", null: false
        t.column :email_verified, "bool", null: false
        t.column :scope, "varchar(4000)", null: false

        t.timestamps
      end
    end

    direction.down do
      execute "DROP TABLE IF EXISTS users;"
    end
  end
end
