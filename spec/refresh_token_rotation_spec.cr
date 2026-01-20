require "./spec_helper"

describe Authority::OpaqueToken do
  describe "refresh token rotation" do
    client_id = "test-client"
    scope = "read write"
    user_id = "user-123"

    before_each do
      # Clean up tokens before each test
      AuthorityDB.tables[:oauth_opaque_tokens].truncate!
    end

    describe ".create_refresh_token" do
      it "creates a refresh token with a new family_id when not provided" do
        token = Authority::OpaqueToken.create_refresh_token(
          client_id: client_id,
          scope: scope,
          user_id: user_id
        )

        token.token_type.should eq "refresh_token"
        token.family_id.should_not be_nil
        token.used_at.should be_nil
      end

      it "creates a refresh token with provided family_id" do
        family_id = UUID.random
        token = Authority::OpaqueToken.create_refresh_token(
          client_id: client_id,
          scope: scope,
          user_id: user_id,
          family_id: family_id
        )

        token.family_id.should eq family_id
      end
    end

    describe "#rotate!" do
      it "creates a new token and marks the old one as used" do
        original = Authority::OpaqueToken.create_refresh_token(
          client_id: client_id,
          scope: scope,
          user_id: user_id
        )

        new_token = original.rotate!

        new_token.should_not be_nil
        new_token = new_token.not_nil!

        # Original should be marked as used
        original_reloaded = Authority::OpaqueToken.find!(original.id!)
        original_reloaded.used?.should be_true
        original_reloaded.used_at.should_not be_nil

        # New token should be in same family
        new_token.family_id.should eq original.family_id
        new_token.used?.should be_false
        new_token.client_id.should eq client_id
        new_token.scope.should eq scope
        new_token.user_id.should eq user_id
      end

      it "returns nil for already used token" do
        token = Authority::OpaqueToken.create_refresh_token(
          client_id: client_id,
          scope: scope
        )

        # First rotation should succeed
        first_rotation = token.rotate!
        first_rotation.should_not be_nil

        # Reload to get used_at
        token_reloaded = Authority::OpaqueToken.find!(token.id!)

        # Second rotation should fail
        second_rotation = token_reloaded.rotate!
        second_rotation.should be_nil
      end

      it "returns nil for revoked token" do
        token = Authority::OpaqueToken.create_refresh_token(
          client_id: client_id,
          scope: scope
        )
        token.revoke!

        token.rotate!.should be_nil
      end

      it "returns nil for expired token" do
        token = Authority::OpaqueToken.create_refresh_token(
          client_id: client_id,
          scope: scope,
          ttl: -1.hour # Already expired
        )

        token.rotate!.should be_nil
      end

      it "returns nil for access tokens" do
        token = Authority::OpaqueToken.create_access_token(
          client_id: client_id,
          scope: scope
        )

        token.rotate!.should be_nil
      end
    end

    describe ".revoke_family!" do
      it "revokes all tokens in a family" do
        family_id = UUID.random

        token1 = Authority::OpaqueToken.create_refresh_token(
          client_id: client_id,
          scope: scope,
          family_id: family_id
        )

        token2 = Authority::OpaqueToken.create_refresh_token(
          client_id: client_id,
          scope: scope,
          family_id: family_id
        )

        # Different family should not be affected
        other_token = Authority::OpaqueToken.create_refresh_token(
          client_id: client_id,
          scope: scope
        )

        Authority::OpaqueToken.revoke_family!(family_id)

        Authority::OpaqueToken.find!(token1.id!).revoked?.should be_true
        Authority::OpaqueToken.find!(token2.id!).revoked?.should be_true
        Authority::OpaqueToken.find!(other_token.id!).revoked?.should be_false
      end
    end

    describe "#reuse_detected?" do
      it "returns true for used but not revoked refresh token" do
        token = Authority::OpaqueToken.create_refresh_token(
          client_id: client_id,
          scope: scope
        )
        token.mark_used!

        token.reuse_detected?.should be_true
      end

      it "returns false for unused token" do
        token = Authority::OpaqueToken.create_refresh_token(
          client_id: client_id,
          scope: scope
        )

        token.reuse_detected?.should be_false
      end

      it "returns false for access tokens" do
        token = Authority::OpaqueToken.create_access_token(
          client_id: client_id,
          scope: scope
        )

        token.reuse_detected?.should be_false
      end
    end
  end
end

describe Authority::OpaqueTokenService do
  describe ".refresh with rotation" do
    client_id = "test-client"
    scope = "read write"
    user_id = "user-123"

    before_each do
      AuthorityDB.tables[:oauth_opaque_tokens].truncate!
    end

    it "returns new access and refresh tokens" do
      # Create initial tokens
      initial = Authority::OpaqueTokenService.create_tokens(
        client_id: client_id,
        scope: scope,
        user_id: user_id
      )

      # Refresh
      result = Authority::OpaqueTokenService.refresh(
        initial.refresh_token.not_nil!,
        client_id
      )

      result.should_not be_nil
      result = result.not_nil!

      # Should have new tokens
      result.access_token.should_not eq initial.access_token
      result.refresh_token.should_not eq initial.refresh_token
      result.scope.should eq scope
    end

    it "marks old refresh token as used" do
      initial = Authority::OpaqueTokenService.create_tokens(
        client_id: client_id,
        scope: scope
      )

      old_refresh = initial.refresh_token.not_nil!

      Authority::OpaqueTokenService.refresh(old_refresh, client_id)

      # Old token should be marked as used
      old_token = Authority::OpaqueToken.find_by(token: old_refresh)
      old_token.should_not be_nil
      old_token.not_nil!.used?.should be_true
    end

    it "returns nil and revokes family on token reuse" do
      initial = Authority::OpaqueTokenService.create_tokens(
        client_id: client_id,
        scope: scope
      )

      old_refresh = initial.refresh_token.not_nil!

      # First refresh should succeed
      first_result = Authority::OpaqueTokenService.refresh(old_refresh, client_id)
      first_result.should_not be_nil

      # Attempt to reuse the old token (simulating attacker)
      second_result = Authority::OpaqueTokenService.refresh(old_refresh, client_id)
      second_result.should be_nil

      # All tokens in the family should be revoked
      old_token = Authority::OpaqueToken.find_by(token: old_refresh)
      old_token.not_nil!.revoked?.should be_true

      new_refresh = first_result.not_nil!.refresh_token.not_nil!
      new_token = Authority::OpaqueToken.find_by(token: new_refresh)
      new_token.not_nil!.revoked?.should be_true
    end

    it "returns nil for wrong client_id" do
      initial = Authority::OpaqueTokenService.create_tokens(
        client_id: client_id,
        scope: scope
      )

      result = Authority::OpaqueTokenService.refresh(
        initial.refresh_token.not_nil!,
        "wrong-client"
      )

      result.should be_nil
    end

    it "returns nil for expired refresh token" do
      token = Authority::OpaqueToken.create_refresh_token(
        client_id: client_id,
        scope: scope,
        ttl: -1.hour
      )

      result = Authority::OpaqueTokenService.refresh(token.token, client_id)
      result.should be_nil
    end

    it "returns nil for revoked refresh token" do
      initial = Authority::OpaqueTokenService.create_tokens(
        client_id: client_id,
        scope: scope
      )

      refresh = initial.refresh_token.not_nil!
      Authority::OpaqueToken.revoke_by_token!(refresh)

      result = Authority::OpaqueTokenService.refresh(refresh, client_id)
      result.should be_nil
    end
  end
end
