# Fix last_login_ip column type from INET to TEXT for proper string handling
class FixLastLoginIpColumnType < CQL::Migration(1768942000_i64)
  def up
    # Change INET to TEXT to avoid byte serialization issues
    schema.exec <<-SQL
      ALTER TABLE oauth_owners
      ALTER COLUMN last_login_ip TYPE TEXT
      USING last_login_ip::TEXT
    SQL
  end

  def down
    schema.exec <<-SQL
      ALTER TABLE oauth_owners
      ALTER COLUMN last_login_ip TYPE INET
      USING last_login_ip::INET
    SQL
  end
end
