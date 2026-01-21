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

      scopes = [
        {name: "openid", display_name: "OpenID", description: "OpenID Connect scope", is_default: true, is_system: true},
        {name: "profile", display_name: "Profile", description: "Access to user profile information", is_default: true, is_system: true},
        {name: "email", display_name: "Email", description: "Access to user email address", is_default: true, is_system: true},
        {name: "offline_access", display_name: "Offline Access", description: "Request refresh tokens for offline access", is_default: false, is_system: true},
        {name: "authority:admin", display_name: "Admin Access", description: "Access to admin dashboard", is_default: false, is_system: true},
        {name: "authority:super_admin", display_name: "Super Admin", description: "Full administrative control including user management", is_default: false, is_system: true},
      ]

      scopes.each do |scope_data|
        existing = Scope.query.where(name: scope_data[:name]).first(as: Scope)
        if existing
          puts "  ⏭️  Scope '#{scope_data[:name]}' already exists, skipping..."
          next
        end

        scope = Scope.new
        scope.name = scope_data[:name]
        scope.display_name = scope_data[:display_name]
        scope.description = scope_data[:description]
        scope.is_default = scope_data[:is_default]
        scope.is_system = scope_data[:is_system]
        scope.created_at = Time.utc
        scope.updated_at = Time.utc
        scope.save!

        puts "  ✓ Created scope: #{scope.name}"
      end
    end

    private def self.seed_admin_user
      puts "\n👤 Seeding admin user..."

      admin_email = ENV.fetch("ADMIN_EMAIL", "admin@authority.local")
      admin_username = ENV.fetch("ADMIN_USERNAME", "admin")
      admin_password = ENV.fetch("ADMIN_PASSWORD", "changeme123")

      existing = User.query.where(email: admin_email).first(as: User)
      if existing
        puts "  ⏭️  Admin user '#{admin_email}' already exists, skipping..."
        return
      end

      admin = User.new
      admin.username = admin_username
      admin.email = admin_email
      admin.first_name = "System"
      admin.last_name = "Administrator"
      admin.password = admin_password
      admin.role = "admin"
      admin.scope = "openid profile email authority:admin authority:super_admin"
      admin.email_verified = true
      admin.failed_login_attempts = 0
      admin.created_at = Time.utc
      admin.updated_at = Time.utc
      admin.save!

      puts "  ✓ Created admin user: #{admin.email}"
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
