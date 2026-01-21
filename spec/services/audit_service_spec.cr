require "../spec_helper"

module AuditTestHelpers
  def self.create_test_admin : Authority::User
    user = Authority::User.new
    user.username = "audit_admin_#{UUID.random.to_s[0, 8]}"
    user.email = "#{user.username}@example.com"
    user.first_name = "Audit"
    user.last_name = "Admin"
    user.password = "password123"
    user.role = "admin"
    user.scope = "authority:admin"
    user.save!
    user
  end

  def self.cleanup_audit_logs(actor_email : String)
    prefix = actor_email.split("@").first
    Authority::AuditLog
      .where { oauth_audit_logs.actor_email.like("#{prefix}%") }
      .delete_all
  end
end

describe Authority::AuditService do
  describe ".log" do
    it "creates an audit log entry" do
      admin = AuditTestHelpers.create_test_admin

      log = Authority::AuditService.log(
        actor: admin,
        action: Authority::AuditLog::Actions::CREATE,
        resource_type: Authority::AuditLog::ResourceTypes::CLIENT,
        resource_id: UUID.random.to_s,
        resource_name: "Test Client",
        ip_address: "192.168.1.100",
        user_agent: "Mozilla/5.0 Test"
      )

      log.should_not be_nil
      log = log.not_nil!
      log.actor_email.should eq(admin.email)
      log.action.should eq("create")
      log.resource_type.should eq("Client")
      log.resource_name.should eq("Test Client")
      log.ip_address.should_not be_nil
      log.user_agent.should eq("Mozilla/5.0 Test")

      AuditTestHelpers.cleanup_audit_logs(admin.email)
      admin.delete!
    end

    it "creates an audit log with changes diff" do
      admin = AuditTestHelpers.create_test_admin

      changes = {
        "name"        => ["Old Name".as(String?), "New Name".as(String?)],
        "description" => [nil.as(String?), "New description".as(String?)],
      } of String => Array(String?)

      log = Authority::AuditService.log(
        actor: admin,
        action: Authority::AuditLog::Actions::UPDATE,
        resource_type: Authority::AuditLog::ResourceTypes::CLIENT,
        resource_id: UUID.random.to_s,
        resource_name: "Test Client",
        changes: changes
      )

      log.should_not be_nil
      log = log.not_nil!
      log.changes.should_not be_nil
      log.action.should eq("update")

      # Verify changes JSON contains expected data
      changes_str = log.changes.not_nil!
      changes_str.should contain("Old Name")
      changes_str.should contain("New Name")

      AuditTestHelpers.cleanup_audit_logs(admin.email)
      admin.delete!
    end

    it "creates an audit log using LogEntry struct" do
      admin = AuditTestHelpers.create_test_admin

      entry = Authority::AuditService::LogEntry.new(
        actor: admin,
        action: Authority::AuditLog::Actions::DELETE,
        resource_type: Authority::AuditLog::ResourceTypes::SCOPE,
        resource_name: "custom:scope"
      )

      log = Authority::AuditService.log(entry)

      log.should_not be_nil
      log = log.not_nil!
      log.action.should eq("delete")
      log.resource_type.should eq("Scope")

      AuditTestHelpers.cleanup_audit_logs(admin.email)
      admin.delete!
    end
  end

  describe ".get" do
    it "retrieves an audit log by ID" do
      admin = AuditTestHelpers.create_test_admin

      created_log = Authority::AuditService.log(
        actor: admin,
        action: Authority::AuditLog::Actions::LOCK,
        resource_type: Authority::AuditLog::ResourceTypes::USER,
        resource_name: "testuser"
      )

      created_log.should_not be_nil
      id = created_log.not_nil!.id.not_nil!

      retrieved = Authority::AuditService.get(id.to_s)
      retrieved.should_not be_nil
      retrieved.not_nil!.action.should eq("lock")

      AuditTestHelpers.cleanup_audit_logs(admin.email)
      admin.delete!
    end

    it "returns nil for non-existent ID" do
      result = Authority::AuditService.get(UUID.random.to_s)
      result.should be_nil
    end
  end

  describe ".list" do
    it "returns paginated audit logs" do
      admin = AuditTestHelpers.create_test_admin

      # Create 5 audit logs
      5.times do |i|
        Authority::AuditService.log(
          actor: admin,
          action: Authority::AuditLog::Actions::CREATE,
          resource_type: Authority::AuditLog::ResourceTypes::CLIENT,
          resource_name: "Client #{i}"
        )
      end

      options = Authority::AuditService::ListOptions.new(
        page: 1,
        per_page: 3
      )

      logs = Authority::AuditService.list(options)
      logs.size.should eq(3)

      AuditTestHelpers.cleanup_audit_logs(admin.email)
      admin.delete!
    end

    it "filters by actor_id" do
      admin1 = AuditTestHelpers.create_test_admin
      admin2 = AuditTestHelpers.create_test_admin

      Authority::AuditService.log(
        actor: admin1,
        action: Authority::AuditLog::Actions::CREATE,
        resource_type: Authority::AuditLog::ResourceTypes::CLIENT,
        resource_name: "Admin1 Client"
      )

      Authority::AuditService.log(
        actor: admin2,
        action: Authority::AuditLog::Actions::CREATE,
        resource_type: Authority::AuditLog::ResourceTypes::CLIENT,
        resource_name: "Admin2 Client"
      )

      options = Authority::AuditService::ListOptions.new(
        actor_id: admin1.id.to_s
      )

      logs = Authority::AuditService.list(options)
      logs.all? { |l| l.actor_id.to_s == admin1.id.to_s }.should be_true

      AuditTestHelpers.cleanup_audit_logs(admin1.email)
      AuditTestHelpers.cleanup_audit_logs(admin2.email)
      admin1.delete!
      admin2.delete!
    end

    it "filters by action" do
      admin = AuditTestHelpers.create_test_admin

      Authority::AuditService.log(
        actor: admin,
        action: Authority::AuditLog::Actions::CREATE,
        resource_type: Authority::AuditLog::ResourceTypes::CLIENT
      )

      Authority::AuditService.log(
        actor: admin,
        action: Authority::AuditLog::Actions::DELETE,
        resource_type: Authority::AuditLog::ResourceTypes::CLIENT
      )

      options = Authority::AuditService::ListOptions.new(
        action: Authority::AuditLog::Actions::DELETE
      )

      logs = Authority::AuditService.list(options)
      logs.all? { |l| l.action == "delete" }.should be_true

      AuditTestHelpers.cleanup_audit_logs(admin.email)
      admin.delete!
    end

    it "filters by resource_type" do
      admin = AuditTestHelpers.create_test_admin

      Authority::AuditService.log(
        actor: admin,
        action: Authority::AuditLog::Actions::CREATE,
        resource_type: Authority::AuditLog::ResourceTypes::CLIENT
      )

      Authority::AuditService.log(
        actor: admin,
        action: Authority::AuditLog::Actions::CREATE,
        resource_type: Authority::AuditLog::ResourceTypes::USER
      )

      options = Authority::AuditService::ListOptions.new(
        resource_type: Authority::AuditLog::ResourceTypes::USER
      )

      logs = Authority::AuditService.list(options)
      logs.all? { |l| l.resource_type == "User" }.should be_true

      AuditTestHelpers.cleanup_audit_logs(admin.email)
      admin.delete!
    end

    it "filters by date range" do
      admin = AuditTestHelpers.create_test_admin

      # Create an old log
      old_log = Authority::AuditLog.new
      old_log.id = UUID.random
      old_log.actor_id = UUID.new(admin.id.to_s)
      old_log.actor_email = admin.email
      old_log.action = "create"
      old_log.resource_type = "Client"
      old_log.created_at = Time.utc - 30.days
      old_log.save!

      # Create a recent log
      Authority::AuditService.log(
        actor: admin,
        action: Authority::AuditLog::Actions::CREATE,
        resource_type: Authority::AuditLog::ResourceTypes::CLIENT
      )

      options = Authority::AuditService::ListOptions.new(
        start_date: Time.utc - 1.days,
        end_date: Time.utc + 1.days
      )

      logs = Authority::AuditService.list(options)
      logs.all? { |l| l.created_at.not_nil! > Time.utc - 2.days }.should be_true

      AuditTestHelpers.cleanup_audit_logs(admin.email)
      admin.delete!
    end
  end

  describe ".count" do
    it "counts audit logs" do
      admin = AuditTestHelpers.create_test_admin

      3.times do
        Authority::AuditService.log(
          actor: admin,
          action: Authority::AuditLog::Actions::CREATE,
          resource_type: Authority::AuditLog::ResourceTypes::CLIENT
        )
      end

      count = Authority::AuditService.count
      count.should be >= 3

      AuditTestHelpers.cleanup_audit_logs(admin.email)
      admin.delete!
    end

    it "counts with filters" do
      admin = AuditTestHelpers.create_test_admin

      2.times do
        Authority::AuditService.log(
          actor: admin,
          action: Authority::AuditLog::Actions::CREATE,
          resource_type: Authority::AuditLog::ResourceTypes::USER
        )
      end

      options = Authority::AuditService::ListOptions.new(
        resource_type: Authority::AuditLog::ResourceTypes::USER,
        actor_id: admin.id.to_s
      )

      count = Authority::AuditService.count(options)
      count.should eq(2)

      AuditTestHelpers.cleanup_audit_logs(admin.email)
      admin.delete!
    end
  end

  describe ".diff" do
    it "calculates changes between old and new values" do
      old_values = {
        "name"        => "Old Name",
        "description" => "Old desc",
        "removed_key" => "value",
      } of String => String?

      new_values = {
        "name"        => "New Name",
        "description" => "Old desc",
        "added_key"   => "new value",
      } of String => String?

      diff = Authority::AuditService.diff(old_values, new_values)

      diff.has_key?("name").should be_true
      diff["name"].should eq(["Old Name", "New Name"])

      diff.has_key?("description").should be_false # unchanged

      diff.has_key?("removed_key").should be_true
      diff["removed_key"].should eq(["value", nil])

      diff.has_key?("added_key").should be_true
      diff["added_key"].should eq([nil, "new value"])
    end
  end

  describe ".distinct_actions" do
    it "returns list of distinct actions" do
      admin = AuditTestHelpers.create_test_admin

      Authority::AuditService.log(
        actor: admin,
        action: Authority::AuditLog::Actions::CREATE,
        resource_type: Authority::AuditLog::ResourceTypes::CLIENT
      )

      Authority::AuditService.log(
        actor: admin,
        action: Authority::AuditLog::Actions::DELETE,
        resource_type: Authority::AuditLog::ResourceTypes::CLIENT
      )

      actions = Authority::AuditService.distinct_actions
      actions.should contain("create")
      actions.should contain("delete")

      AuditTestHelpers.cleanup_audit_logs(admin.email)
      admin.delete!
    end
  end

  describe ".distinct_actors" do
    it "returns list of distinct actors" do
      admin = AuditTestHelpers.create_test_admin

      Authority::AuditService.log(
        actor: admin,
        action: Authority::AuditLog::Actions::CREATE,
        resource_type: Authority::AuditLog::ResourceTypes::CLIENT
      )

      actors = Authority::AuditService.distinct_actors
      actors.any? { |a| a[:email] == admin.email }.should be_true

      AuditTestHelpers.cleanup_audit_logs(admin.email)
      admin.delete!
    end
  end

  describe "AuditLog model helpers" do
    it "returns correct badge class for action" do
      log = Authority::AuditLog.new
      log.action = "create"
      log.action_badge_class.should eq("badge-success")

      log.action = "update"
      log.action_badge_class.should eq("badge-info")

      log.action = "delete"
      log.action_badge_class.should eq("badge-error")

      log.action = "lock"
      log.action_badge_class.should eq("badge-warning")

      log.action = "unlock"
      log.action_badge_class.should eq("badge-success")
    end

    it "returns correct action label" do
      log = Authority::AuditLog.new
      log.action = "create"
      log.action_label.should eq("Created")

      log.action = "reset_password"
      log.action_label.should eq("Password Reset")

      log.action = "regenerate_secret"
      log.action_label.should eq("Secret Regenerated")
    end
  end
end
