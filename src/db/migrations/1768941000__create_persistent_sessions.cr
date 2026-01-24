# Migration to create persistent_sessions table for tracking user sessions
class CreatePersistentSessions < CQL::Migration(1768941000)
  def up
    schema.alter :users do
      # Nothing to add to users table
    end

    schema.create :persistent_sessions, if_not_exists: true do
      primary_key :id, type: :uuid
      column :user_id, type: :uuid, null: false
      column :session_token, type: :text, null: false
      column :ip_address, type: :text
      column :user_agent, type: :text
      column :device_info, type: :text
      column :last_activity_at, type: :timestamp, null: false
      column :expires_at, type: :timestamp, null: false
      column :created_at, type: :timestamp, null: false
      column :revoked_at, type: :timestamp

      index [:session_token], unique: true
      index [:user_id]
      index [:expires_at]
    end
  end

  def down
    schema.drop :persistent_sessions, if_exists: true
  end
end
