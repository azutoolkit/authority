require "../spec_helper"

describe Authority::AdminScopeService do
  describe ".list" do
    it "returns an array of scopes" do
      result = Authority::AdminScopeService.list
      result.should be_a(Array(Authority::Scope))
    end

    it "includes system scopes" do
      result = Authority::AdminScopeService.list
      system_scopes = result.select(&.is_system?)
      system_scopes.size.should be >= 4 # openid, profile, email, offline_access
    end

    it "respects pagination" do
      options = Authority::AdminScopeService.list(page: 1, per_page: 2)
      options.size.should be <= 2
    end
  end

  describe ".count" do
    it "returns total count of scopes" do
      count = Authority::AdminScopeService.count
      count.should be >= 4 # At least the 4 system scopes
    end
  end

  describe ".get" do
    it "returns a scope by ID" do
      # Get existing system scope
      scopes = Authority::AdminScopeService.list
      scope = scopes.first

      fetched = Authority::AdminScopeService.get(scope.id.to_s)
      fetched.should_not be_nil
      fetched.try(&.name).should eq scope.name
    end

    it "returns nil for non-existent ID" do
      scope = Authority::AdminScopeService.get(UUID.random.to_s)
      scope.should be_nil
    end
  end

  describe ".get_by_name" do
    it "returns a scope by name" do
      scope = Authority::AdminScopeService.get_by_name("openid")
      scope.should_not be_nil
      scope.try(&.name).should eq "openid"
    end

    it "returns nil for non-existent name" do
      scope = Authority::AdminScopeService.get_by_name("nonexistent_scope")
      scope.should be_nil
    end
  end

  describe ".default_scopes" do
    it "returns only default scopes" do
      result = Authority::AdminScopeService.default_scopes
      result.all?(&.is_default?).should be_true
    end

    it "includes openid as default" do
      result = Authority::AdminScopeService.default_scopes
      result.any? { |scope| scope.name == "openid" }.should be_true
    end
  end

  describe ".create" do
    it "creates a new scope" do
      name = "test_scope_#{UUID.random.to_s[0..7]}"
      result = Authority::AdminScopeService.create(
        name: name,
        display_name: "Test Scope",
        description: "A test scope"
      )

      result.success?.should be_true
      result.scope.should_not be_nil
      result.scope.try(&.name).should eq name
    end

    it "can create scope with is_default true" do
      name = "default_#{UUID.random.to_s[0..7]}"
      result = Authority::AdminScopeService.create(
        name: name,
        display_name: "Default Scope",
        is_default: true
      )

      result.success?.should be_true
      result.scope.try(&.is_default?).should be_true
    end

    it "creates scope with is_system false" do
      name = "nonsystem_#{UUID.random.to_s[0..7]}"
      result = Authority::AdminScopeService.create(
        name: name,
        display_name: "Non-System Scope"
      )

      result.success?.should be_true
      result.scope.try(&.is_system?).should be_false
    end

    it "fails with empty name" do
      result = Authority::AdminScopeService.create(
        name: "",
        display_name: "Empty Name"
      )

      result.success?.should be_false
      result.error_code.should eq "validation_error"
    end

    it "fails with empty display_name" do
      result = Authority::AdminScopeService.create(
        name: "valid_name",
        display_name: ""
      )

      result.success?.should be_false
      result.error_code.should eq "validation_error"
    end

    it "fails with invalid name format" do
      result = Authority::AdminScopeService.create(
        name: "Invalid Name!",
        display_name: "Invalid"
      )

      result.success?.should be_false
      result.error_code.should eq "invalid_name"
    end

    it "allows colons in scope names" do
      name = "authority:admin_#{UUID.random.to_s[0..7]}"
      result = Authority::AdminScopeService.create(
        name: name,
        display_name: "Admin Scope"
      )

      result.success?.should be_true
      result.scope.try(&.name).should eq name
    end

    it "fails with duplicate name" do
      name = "dup_#{UUID.random.to_s[0..7]}"
      Authority::AdminScopeService.create(
        name: name,
        display_name: "First"
      )

      result = Authority::AdminScopeService.create(
        name: name,
        display_name: "Second"
      )

      result.success?.should be_false
      result.error_code.should eq "duplicate_name"
    end
  end

  describe ".update" do
    it "updates scope metadata" do
      name = "update_#{UUID.random.to_s[0..7]}"
      create_result = Authority::AdminScopeService.create(
        name: name,
        display_name: "Original"
      )
      create_result.scope.should_not be_nil

      if scope = create_result.scope
        result = Authority::AdminScopeService.update(
          id: scope.id.to_s,
          display_name: "Updated"
        )

        result.success?.should be_true
        result.scope.try(&.display_name).should eq "Updated"
      end
    end

    it "can update is_default" do
      name = "updatedefault_#{UUID.random.to_s[0..7]}"
      create_result = Authority::AdminScopeService.create(
        name: name,
        display_name: "Update Default",
        is_default: false
      )
      create_result.scope.should_not be_nil

      if scope = create_result.scope
        result = Authority::AdminScopeService.update(
          id: scope.id.to_s,
          is_default: true
        )

        result.success?.should be_true
        result.scope.try(&.is_default?).should be_true
      end
    end

    it "fails for non-existent scope" do
      result = Authority::AdminScopeService.update(
        id: UUID.random.to_s,
        display_name: "Ghost"
      )

      result.success?.should be_false
      result.error_code.should eq "not_found"
    end

    it "prevents modifying system scopes" do
      # Get a system scope
      openid = Authority::AdminScopeService.get_by_name("openid")
      openid.should_not be_nil

      if scope = openid
        result = Authority::AdminScopeService.update(
          id: scope.id.to_s,
          display_name: "Modified OpenID"
        )

        result.success?.should be_false
        result.error_code.should eq "system_scope_protected"
      end
    end

    it "prevents duplicate name on update" do
      name1 = "unique1_#{UUID.random.to_s[0..7]}"
      name2 = "unique2_#{UUID.random.to_s[0..7]}"

      Authority::AdminScopeService.create(
        name: name1,
        display_name: "Scope One"
      )

      create_result = Authority::AdminScopeService.create(
        name: name2,
        display_name: "Scope Two"
      )
      create_result.scope.should_not be_nil

      if scope2 = create_result.scope
        result = Authority::AdminScopeService.update(
          id: scope2.id.to_s,
          name: name1
        )

        result.success?.should be_false
        result.error_code.should eq "duplicate_name"
      end
    end
  end

  describe ".delete" do
    it "deletes a scope" do
      # Create admin actor
      actor_result = Authority::AdminUserService.create(
        username: "scopedeleter_#{UUID.random.to_s[0..7]}",
        email: "scopedeleter_#{UUID.random.to_s[0..7]}@test.com",
        password: "Password123!",
        first_name: "Scope",
        last_name: "Deleter",
        role: "admin"
      )
      actor_result.user.should_not be_nil

      # Create a scope
      name = "delete_#{UUID.random.to_s[0..7]}"
      create_result = Authority::AdminScopeService.create(
        name: name,
        display_name: "To Delete"
      )
      create_result.scope.should_not be_nil

      if actor = actor_result.user
        if scope = create_result.scope
          result = Authority::AdminScopeService.delete(
            id: scope.id.to_s,
            actor: actor
          )

          result.success?.should be_true
          Authority::AdminScopeService.get(scope.id.to_s).should be_nil
        end
      end
    end

    it "prevents deleting system scopes" do
      # Create admin actor
      actor_result = Authority::AdminUserService.create(
        username: "sysdeleter_#{UUID.random.to_s[0..7]}",
        email: "sysdeleter_#{UUID.random.to_s[0..7]}@test.com",
        password: "Password123!",
        first_name: "System",
        last_name: "Deleter",
        role: "admin"
      )
      actor_result.user.should_not be_nil

      # Try to delete a system scope
      openid = Authority::AdminScopeService.get_by_name("openid")
      openid.should_not be_nil

      if actor = actor_result.user
        if scope = openid
          result = Authority::AdminScopeService.delete(
            id: scope.id.to_s,
            actor: actor
          )

          result.success?.should be_false
          result.error_code.should eq "system_scope_protected"
        end
      end
    end

    it "fails for non-existent scope" do
      actor_result = Authority::AdminUserService.create(
        username: "ghostdeleter_#{UUID.random.to_s[0..7]}",
        email: "ghostdeleter_#{UUID.random.to_s[0..7]}@test.com",
        password: "Password123!",
        first_name: "Ghost",
        last_name: "Deleter",
        role: "admin"
      )
      actor_result.user.should_not be_nil

      if actor = actor_result.user
        result = Authority::AdminScopeService.delete(
          id: UUID.random.to_s,
          actor: actor
        )

        result.success?.should be_false
        result.error_code.should eq "not_found"
      end
    end
  end
end
