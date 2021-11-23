class CreateDeviceCode
  include Clear::Migration

  def change(direction)
    direction.up do
      create_enum("verification", %w(allowed denied pending))

      create_table :device_codes, id: :uuid do |t|
        t.column :client_id, "varchar(80)", null: false, index: true, unique: false
        t.column :client_name, "varchar(80)", null: false
        t.column :user_code, "varchar(10)", null: false, index: true, unique: false
        t.column :verification, :verification, null: false
        t.column :verification_uri, "varchar(1000)", null: false
        t.column :expires_at, "TIMESTAMPTZ", index: true, default: "CURRENT_TIMESTAMP"

        t.timestamps
      end
    end

    direction.down do
      execute "DROP TABLE IF EXISTS device_codes;"
      execute "DROP TYPE IF EXISTS verification;"
    end
  end
end
