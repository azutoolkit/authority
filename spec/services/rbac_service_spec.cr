require "../spec_helper"

# Helper to create test user
def create_rbac_test_user(
  username : String = "test_user_#{Random.rand(10000)}",
  role : String = "user",
  scope : String = ""
) : Authority::User
  user = Authority::User.new
  user.username = username
  user.email = "#{username}@example.com"
  user.first_name = "Test"
  user.last_name = "User"
  user.password = "password123"
  user.role = role
  user.scope = scope
  user.save!
  user
end

describe Authority::RBACService do
  Spec.before_each do
    AuthorityDB.exec_query { |conn| conn.exec("TRUNCATE TABLE oauth_owners CASCADE") }
  end

  describe ".admin?" do
    it "returns true for user with admin role" do
      admin = create_rbac_test_user(role: "admin")
      Authority::RBACService.admin?(admin).should be_true
    end

    it "returns true for user with authority:admin scope" do
      admin = create_rbac_test_user(scope: "read write authority:admin")
      Authority::RBACService.admin?(admin).should be_true
    end

    it "returns false for regular user" do
      user = create_rbac_test_user(role: "user", scope: "read write")
      Authority::RBACService.admin?(user).should be_false
    end

    it "returns false for locked admin" do
      admin = create_rbac_test_user(role: "admin")
      admin.locked_at = Time.utc
      admin.lock_reason = "Test lock"
      admin.save!

      Authority::RBACService.admin?(admin).should be_false
    end
  end

  describe ".has_scope?" do
    it "returns true when user has the scope" do
      user = create_rbac_test_user(scope: "read write openid")
      Authority::RBACService.has_scope?(user, "write").should be_true
    end

    it "returns false when user doesn't have the scope" do
      user = create_rbac_test_user(scope: "read openid")
      Authority::RBACService.has_scope?(user, "write").should be_false
    end

    it "handles comma-separated scopes" do
      user = create_rbac_test_user(scope: "read,write,openid")
      Authority::RBACService.has_scope?(user, "write").should be_true
    end

    it "handles empty scope" do
      user = create_rbac_test_user(scope: "")
      Authority::RBACService.has_scope?(user, "read").should be_false
    end
  end

  describe ".can_manage_user?" do
    it "allows admin to manage regular user" do
      admin = create_rbac_test_user(username: "admin", role: "admin")
      user = create_rbac_test_user(username: "regular", role: "user")

      Authority::RBACService.can_manage_user?(admin, user).should be_true
    end

    it "prevents admin from managing themselves" do
      admin = create_rbac_test_user(role: "admin")
      Authority::RBACService.can_manage_user?(admin, admin).should be_false
    end

    it "prevents regular admin from managing other admins" do
      admin1 = create_rbac_test_user(username: "admin1", role: "admin")
      admin2 = create_rbac_test_user(username: "admin2", role: "admin")

      Authority::RBACService.can_manage_user?(admin1, admin2).should be_false
    end

    it "allows super admin to manage other admins" do
      super_admin = create_rbac_test_user(
        username: "super_admin",
        role: "admin",
        scope: "authority:admin authority:super_admin"
      )
      admin = create_rbac_test_user(username: "admin", role: "admin")

      Authority::RBACService.can_manage_user?(super_admin, admin).should be_true
    end

    it "prevents non-admin from managing anyone" do
      user1 = create_rbac_test_user(username: "user1", role: "user")
      user2 = create_rbac_test_user(username: "user2", role: "user")

      Authority::RBACService.can_manage_user?(user1, user2).should be_false
    end
  end

  describe ".can_access_admin?" do
    it "returns true for admin" do
      admin = create_rbac_test_user(role: "admin")
      Authority::RBACService.can_access_admin?(admin).should be_true
    end

    it "returns false for regular user" do
      user = create_rbac_test_user(role: "user")
      Authority::RBACService.can_access_admin?(user).should be_false
    end
  end
end
