require "../authority"

module Authority
  class Seeder
    def self.run
      puts "🌱 Starting database seeding..."

      seed_scopes
      seed_admin_user

      puts "✅ Database seeding completed!"
    end

    private def self.seed_scopes
      puts "\n📋 Seeding OAuth scopes..."

      # Use ON CONFLICT to handle existing scopes gracefully
      AuthorityDB.exec <<-SQL
        INSERT INTO oauth_scopes (name, display_name, description, is_default, is_system, created_at, updated_at)
        VALUES
          ('authority:admin', 'Admin Access', 'Access to admin dashboard', false, true, NOW(), NOW()),
          ('authority:super_admin', 'Super Admin', 'Full administrative control including user management', false, true, NOW(), NOW())
        ON CONFLICT (name) DO NOTHING
      SQL
      puts "  ✓ Admin scopes ensured"
    end

    private def self.seed_admin_user
      puts "\n👤 Seeding admin user..."

      admin_email = ENV.fetch("ADMIN_EMAIL", "admin@authority.local")
      admin_username = ENV.fetch("ADMIN_USERNAME", "admin")
      admin_password = ENV.fetch("ADMIN_PASSWORD", "changeme123")

      # Hash the password using bcrypt
      encrypted_password = Crypto::Bcrypt::Password.create(admin_password).to_s

      # Use raw SQL to bypass ORM UUID issues
      AuthorityDB.exec <<-SQL
        INSERT INTO oauth_owners (
          id, username, email, first_name, last_name, encrypted_password,
          role, scope, email_verified, failed_login_attempts, created_at, updated_at
        )
        VALUES (
          uuid_generate_v4(),
          '#{admin_username}',
          '#{admin_email}',
          'System',
          'Administrator',
          '#{encrypted_password}',
          'admin',
          'openid profile email authority:admin authority:super_admin',
          true,
          0,
          NOW(),
          NOW()
        )
        ON CONFLICT (username) DO NOTHING
      SQL

      puts "  ✓ Admin user ensured: #{admin_email}"
      puts ""
      puts "  ┌─────────────────────────────────────────────┐"
      puts "  │ Admin Credentials                           │"
      puts "  ├─────────────────────────────────────────────┤"
      puts "  │ Email:    #{admin_email.ljust(32)}│"
      puts "  │ Password: #{admin_password.ljust(32)}│"
      puts "  └─────────────────────────────────────────────┘"
      puts ""
      puts "  ⚠️  Change the password after first login!"
    end
  end
end

Authority::Seeder.run
