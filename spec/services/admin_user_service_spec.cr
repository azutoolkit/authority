require "../spec_helper"

describe Authority::AdminUserService do
  describe ".list" do
    it "returns an array of users" do
      result = Authority::AdminUserService.list
      result.should be_a(Array(Authority::User))
    end

    it "respects pagination" do
      options = Authority::AdminUserService::ListOptions.new(page: 1, per_page: 5)
      result = Authority::AdminUserService.list(options)
      result.size.should be <= 5
    end

    it "filters by search term" do
      # Create a user with a unique name
      unique_name = "searchtest_#{UUID.random.to_s[0..7]}"
      Authority::AdminUserService.create(
        username: unique_name,
        email: "#{unique_name}@test.com",
        password: "password123",
        first_name: "Search",
        last_name: "Test"
      )

      options = Authority::AdminUserService::ListOptions.new(search: unique_name)
      result = Authority::AdminUserService.list(options)
      result.size.should eq 1
      result.first.username.should eq unique_name
    end

    it "filters by role" do
      # Create an admin user
      admin_username = "admintest_#{UUID.random.to_s[0..7]}"
      Authority::AdminUserService.create(
        username: admin_username,
        email: "#{admin_username}@test.com",
        password: "password123",
        first_name: "Admin",
        last_name: "Test",
        role: "admin"
      )

      options = Authority::AdminUserService::ListOptions.new(role: "admin")
      result = Authority::AdminUserService.list(options)
      result.all? { |u| u.role == "admin" }.should be_true
    end

    it "filters by status (active)" do
      options = Authority::AdminUserService::ListOptions.new(status: "active")
      result = Authority::AdminUserService.list(options)
      result.all? { |u| !u.locked? }.should be_true
    end

    it "filters by status (locked)" do
      options = Authority::AdminUserService::ListOptions.new(status: "locked")
      result = Authority::AdminUserService.list(options)
      result.all? { |u| u.locked? }.should be_true
    end
  end

  describe ".count" do
    it "returns total count of users" do
      count = Authority::AdminUserService.count
      count.should be >= 0
    end

    it "respects filters in count" do
      options = Authority::AdminUserService::ListOptions.new(role: "admin")
      count = Authority::AdminUserService.count(options)
      count.should be >= 0
    end
  end

  describe ".get" do
    it "returns a user by ID" do
      # Create a user first
      username = "gettest_#{UUID.random.to_s[0..7]}"
      create_result = Authority::AdminUserService.create(
        username: username,
        email: "#{username}@test.com",
        password: "password123",
        first_name: "Get",
        last_name: "Test"
      )
      create_result.success?.should be_true
      created_user = create_result.user.not_nil!

      # Fetch it
      user = Authority::AdminUserService.get(created_user.id.to_s)
      user.should_not be_nil
      user.not_nil!.username.should eq username
    end

    it "returns nil for non-existent ID" do
      user = Authority::AdminUserService.get(UUID.random.to_s)
      user.should be_nil
    end
  end

  describe ".create" do
    it "creates a new user" do
      username = "create_#{UUID.random.to_s[0..7]}"
      result = Authority::AdminUserService.create(
        username: username,
        email: "#{username}@test.com",
        password: "password123",
        first_name: "Create",
        last_name: "Test"
      )

      result.success?.should be_true
      result.user.should_not be_nil
      result.user.not_nil!.username.should eq username
    end

    it "hashes the password" do
      username = "hash_#{UUID.random.to_s[0..7]}"
      result = Authority::AdminUserService.create(
        username: username,
        email: "#{username}@test.com",
        password: "password123",
        first_name: "Hash",
        last_name: "Test"
      )

      result.success?.should be_true
      user = result.user.not_nil!
      user.encrypted_password.should_not eq "password123"
      user.verify?("password123").should be_true
    end

    it "sets default role to user" do
      username = "role_#{UUID.random.to_s[0..7]}"
      result = Authority::AdminUserService.create(
        username: username,
        email: "#{username}@test.com",
        password: "password123",
        first_name: "Role",
        last_name: "Test"
      )

      result.success?.should be_true
      result.user.not_nil!.role.should eq "user"
    end

    it "can create admin user" do
      username = "admincreate_#{UUID.random.to_s[0..7]}"
      result = Authority::AdminUserService.create(
        username: username,
        email: "#{username}@test.com",
        password: "password123",
        first_name: "Admin",
        last_name: "Create",
        role: "admin"
      )

      result.success?.should be_true
      result.user.not_nil!.role.should eq "admin"
    end

    it "fails with empty username" do
      result = Authority::AdminUserService.create(
        username: "",
        email: "empty@test.com",
        password: "password123",
        first_name: "Empty",
        last_name: "User"
      )

      result.success?.should be_false
      result.error_code.should eq "validation_error"
    end

    it "fails with duplicate username" do
      username = "dup_#{UUID.random.to_s[0..7]}"
      Authority::AdminUserService.create(
        username: username,
        email: "#{username}@test.com",
        password: "password123",
        first_name: "Dup",
        last_name: "Test"
      )

      result = Authority::AdminUserService.create(
        username: username,
        email: "#{username}2@test.com",
        password: "password123",
        first_name: "Dup",
        last_name: "Again"
      )

      result.success?.should be_false
      result.error_code.should eq "duplicate_username"
    end

    it "fails with duplicate email" do
      unique_email = "dupemail_#{UUID.random.to_s[0..7]}@test.com"
      Authority::AdminUserService.create(
        username: "dup1_#{UUID.random.to_s[0..7]}",
        email: unique_email,
        password: "password123",
        first_name: "Dup",
        last_name: "Email"
      )

      result = Authority::AdminUserService.create(
        username: "dup2_#{UUID.random.to_s[0..7]}",
        email: unique_email,
        password: "password123",
        first_name: "Dup",
        last_name: "Again"
      )

      result.success?.should be_false
      result.error_code.should eq "duplicate_email"
    end
  end

  describe ".update" do
    it "updates user metadata" do
      username = "update_#{UUID.random.to_s[0..7]}"
      create_result = Authority::AdminUserService.create(
        username: username,
        email: "#{username}@test.com",
        password: "password123",
        first_name: "Update",
        last_name: "Test"
      )
      user = create_result.user.not_nil!

      result = Authority::AdminUserService.update(
        id: user.id.to_s,
        first_name: "Updated",
        last_name: "Name"
      )

      result.success?.should be_true
      result.user.not_nil!.first_name.should eq "Updated"
      result.user.not_nil!.last_name.should eq "Name"
    end

    it "can change user role" do
      username = "rolechange_#{UUID.random.to_s[0..7]}"
      create_result = Authority::AdminUserService.create(
        username: username,
        email: "#{username}@test.com",
        password: "password123",
        first_name: "Role",
        last_name: "Change"
      )
      user = create_result.user.not_nil!

      result = Authority::AdminUserService.update(
        id: user.id.to_s,
        role: "admin"
      )

      result.success?.should be_true
      result.user.not_nil!.role.should eq "admin"
    end

    it "fails for non-existent user" do
      result = Authority::AdminUserService.update(
        id: UUID.random.to_s,
        first_name: "Ghost"
      )

      result.success?.should be_false
      result.error_code.should eq "not_found"
    end

    it "prevents duplicate username on update" do
      username1 = "unique1_#{UUID.random.to_s[0..7]}"
      username2 = "unique2_#{UUID.random.to_s[0..7]}"

      Authority::AdminUserService.create(
        username: username1,
        email: "#{username1}@test.com",
        password: "password123",
        first_name: "User",
        last_name: "One"
      )

      create_result = Authority::AdminUserService.create(
        username: username2,
        email: "#{username2}@test.com",
        password: "password123",
        first_name: "User",
        last_name: "Two"
      )
      user2 = create_result.user.not_nil!

      result = Authority::AdminUserService.update(
        id: user2.id.to_s,
        username: username1
      )

      result.success?.should be_false
      result.error_code.should eq "duplicate_username"
    end
  end

  describe ".lock" do
    it "locks a user account" do
      # Create actor (admin)
      actor_username = "actor_#{UUID.random.to_s[0..7]}"
      actor_result = Authority::AdminUserService.create(
        username: actor_username,
        email: "#{actor_username}@test.com",
        password: "password123",
        first_name: "Actor",
        last_name: "Admin",
        role: "admin"
      )
      actor = actor_result.user.not_nil!

      # Create target user
      target_username = "target_#{UUID.random.to_s[0..7]}"
      target_result = Authority::AdminUserService.create(
        username: target_username,
        email: "#{target_username}@test.com",
        password: "password123",
        first_name: "Target",
        last_name: "User"
      )
      target = target_result.user.not_nil!

      result = Authority::AdminUserService.lock(
        id: target.id.to_s,
        reason: "Test lock",
        actor: actor
      )

      result.success?.should be_true
      result.user.not_nil!.locked?.should be_true
      result.user.not_nil!.lock_reason.should eq "Test lock"
    end

    it "prevents locking yourself" do
      actor_username = "selflock_#{UUID.random.to_s[0..7]}"
      actor_result = Authority::AdminUserService.create(
        username: actor_username,
        email: "#{actor_username}@test.com",
        password: "password123",
        first_name: "Self",
        last_name: "Lock",
        role: "admin"
      )
      actor = actor_result.user.not_nil!

      result = Authority::AdminUserService.lock(
        id: actor.id.to_s,
        reason: "Self lock",
        actor: actor
      )

      result.success?.should be_false
      result.error_code.should eq "self_lock_forbidden"
    end

    it "prevents non-super-admin from locking admin" do
      # Create regular admin actor
      actor_username = "regadmin_#{UUID.random.to_s[0..7]}"
      actor_result = Authority::AdminUserService.create(
        username: actor_username,
        email: "#{actor_username}@test.com",
        password: "password123",
        first_name: "Regular",
        last_name: "Admin",
        role: "admin"
      )
      actor = actor_result.user.not_nil!

      # Create another admin
      target_username = "otheradmin_#{UUID.random.to_s[0..7]}"
      target_result = Authority::AdminUserService.create(
        username: target_username,
        email: "#{target_username}@test.com",
        password: "password123",
        first_name: "Other",
        last_name: "Admin",
        role: "admin"
      )
      target = target_result.user.not_nil!

      result = Authority::AdminUserService.lock(
        id: target.id.to_s,
        reason: "Admin lock",
        actor: actor
      )

      result.success?.should be_false
      result.error_code.should eq "admin_lock_forbidden"
    end
  end

  describe ".unlock" do
    it "unlocks a locked user" do
      # Create actor
      actor_username = "unlocker_#{UUID.random.to_s[0..7]}"
      actor_result = Authority::AdminUserService.create(
        username: actor_username,
        email: "#{actor_username}@test.com",
        password: "password123",
        first_name: "Unlocker",
        last_name: "Admin",
        role: "admin"
      )
      actor = actor_result.user.not_nil!

      # Create and lock target
      target_username = "locked_#{UUID.random.to_s[0..7]}"
      target_result = Authority::AdminUserService.create(
        username: target_username,
        email: "#{target_username}@test.com",
        password: "password123",
        first_name: "Locked",
        last_name: "User"
      )
      target = target_result.user.not_nil!

      Authority::AdminUserService.lock(
        id: target.id.to_s,
        reason: "Test",
        actor: actor
      )

      result = Authority::AdminUserService.unlock(
        id: target.id.to_s,
        actor: actor
      )

      result.success?.should be_true
      result.user.not_nil!.locked?.should be_false
      result.user.not_nil!.lock_reason.should be_nil
    end

    it "fails if user is not locked" do
      actor_username = "unlockerr_#{UUID.random.to_s[0..7]}"
      actor_result = Authority::AdminUserService.create(
        username: actor_username,
        email: "#{actor_username}@test.com",
        password: "password123",
        first_name: "Unlocker",
        last_name: "Admin",
        role: "admin"
      )
      actor = actor_result.user.not_nil!

      target_username = "notlocked_#{UUID.random.to_s[0..7]}"
      target_result = Authority::AdminUserService.create(
        username: target_username,
        email: "#{target_username}@test.com",
        password: "password123",
        first_name: "Not",
        last_name: "Locked"
      )
      target = target_result.user.not_nil!

      result = Authority::AdminUserService.unlock(
        id: target.id.to_s,
        actor: actor
      )

      result.success?.should be_false
      result.error_code.should eq "not_locked"
    end
  end

  describe ".set_temp_password" do
    it "sets a new password" do
      actor_username = "pwdactor_#{UUID.random.to_s[0..7]}"
      actor_result = Authority::AdminUserService.create(
        username: actor_username,
        email: "#{actor_username}@test.com",
        password: "password123",
        first_name: "Password",
        last_name: "Actor",
        role: "admin"
      )
      actor = actor_result.user.not_nil!

      target_username = "pwdtarget_#{UUID.random.to_s[0..7]}"
      target_result = Authority::AdminUserService.create(
        username: target_username,
        email: "#{target_username}@test.com",
        password: "oldpassword",
        first_name: "Password",
        last_name: "Target"
      )
      target = target_result.user.not_nil!

      result = Authority::AdminUserService.set_temp_password(
        id: target.id.to_s,
        password: "newpassword",
        actor: actor
      )

      result.success?.should be_true
      updated_user = Authority::AdminUserService.get(target.id.to_s).not_nil!
      updated_user.verify?("newpassword").should be_true
      updated_user.verify?("oldpassword").should be_false
    end

    it "fails with empty password" do
      actor_username = "emptyactor_#{UUID.random.to_s[0..7]}"
      actor_result = Authority::AdminUserService.create(
        username: actor_username,
        email: "#{actor_username}@test.com",
        password: "password123",
        first_name: "Empty",
        last_name: "Actor",
        role: "admin"
      )
      actor = actor_result.user.not_nil!

      target_username = "emptytarget_#{UUID.random.to_s[0..7]}"
      target_result = Authority::AdminUserService.create(
        username: target_username,
        email: "#{target_username}@test.com",
        password: "password123",
        first_name: "Empty",
        last_name: "Target"
      )
      target = target_result.user.not_nil!

      result = Authority::AdminUserService.set_temp_password(
        id: target.id.to_s,
        password: "",
        actor: actor
      )

      result.success?.should be_false
      result.error_code.should eq "validation_error"
    end
  end

  describe ".delete" do
    it "deletes a user" do
      actor_username = "delactor_#{UUID.random.to_s[0..7]}"
      actor_result = Authority::AdminUserService.create(
        username: actor_username,
        email: "#{actor_username}@test.com",
        password: "password123",
        first_name: "Delete",
        last_name: "Actor",
        role: "admin"
      )
      actor = actor_result.user.not_nil!

      target_username = "deltarget_#{UUID.random.to_s[0..7]}"
      target_result = Authority::AdminUserService.create(
        username: target_username,
        email: "#{target_username}@test.com",
        password: "password123",
        first_name: "Delete",
        last_name: "Target"
      )
      target = target_result.user.not_nil!

      result = Authority::AdminUserService.delete(
        id: target.id.to_s,
        actor: actor
      )

      result.success?.should be_true
      Authority::AdminUserService.get(target.id.to_s).should be_nil
    end

    it "prevents self-deletion" do
      actor_username = "selfdelete_#{UUID.random.to_s[0..7]}"
      actor_result = Authority::AdminUserService.create(
        username: actor_username,
        email: "#{actor_username}@test.com",
        password: "password123",
        first_name: "Self",
        last_name: "Delete",
        role: "admin"
      )
      actor = actor_result.user.not_nil!

      result = Authority::AdminUserService.delete(
        id: actor.id.to_s,
        actor: actor
      )

      result.success?.should be_false
      result.error_code.should eq "self_delete_forbidden"
    end

    it "prevents non-super-admin from deleting admin" do
      actor_username = "deladmin1_#{UUID.random.to_s[0..7]}"
      actor_result = Authority::AdminUserService.create(
        username: actor_username,
        email: "#{actor_username}@test.com",
        password: "password123",
        first_name: "Regular",
        last_name: "Admin",
        role: "admin"
      )
      actor = actor_result.user.not_nil!

      target_username = "deladmin2_#{UUID.random.to_s[0..7]}"
      target_result = Authority::AdminUserService.create(
        username: target_username,
        email: "#{target_username}@test.com",
        password: "password123",
        first_name: "Other",
        last_name: "Admin",
        role: "admin"
      )
      target = target_result.user.not_nil!

      result = Authority::AdminUserService.delete(
        id: target.id.to_s,
        actor: actor
      )

      result.success?.should be_false
      result.error_code.should eq "admin_delete_forbidden"
    end
  end

  describe ".record_login" do
    it "records login time and IP" do
      username = "login_#{UUID.random.to_s[0..7]}"
      create_result = Authority::AdminUserService.create(
        username: username,
        email: "#{username}@test.com",
        password: "password123",
        first_name: "Login",
        last_name: "Test"
      )
      user = create_result.user.not_nil!

      result = Authority::AdminUserService.record_login(user.id.to_s, "192.168.1.100")

      result.success?.should be_true
      updated = result.user
      updated.should_not be_nil
      if user = updated
        # INET type returns CIDR notation (e.g., "192.168.1.100/32")
        ip = user.last_login_ip
        ip.should_not be_nil
        ip.should start_with("192.168.1.100") if ip
        user.last_login_at.should_not be_nil
        user.failed_login_attempts.should eq 0
      end
    end
  end

  describe ".record_failed_login" do
    it "increments failed login attempts" do
      username = "failed_#{UUID.random.to_s[0..7]}"
      create_result = Authority::AdminUserService.create(
        username: username,
        email: "#{username}@test.com",
        password: "password123",
        first_name: "Failed",
        last_name: "Login"
      )
      user = create_result.user.not_nil!
      initial_attempts = user.failed_login_attempts

      result = Authority::AdminUserService.record_failed_login(user.id.to_s)

      result.success?.should be_true
      result.user.not_nil!.failed_login_attempts.should eq initial_attempts + 1
    end
  end
end
