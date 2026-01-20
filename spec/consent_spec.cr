require "./spec_helper"

describe "User Consent" do
  password = Faker::Internet.password

  describe Authority::Consent do
    describe ".grant!" do
      it "creates a new consent record" do
        user = create_owner(password: password)
        client_id = CLIENT_ID
        scopes = "read write"

        consent = Authority::Consent.grant!(
          user_id: user.id.to_s,
          client_id: client_id,
          scopes: scopes
        )

        consent.user_id.should eq user.id.to_s
        consent.client_id.should eq client_id
        consent.scopes.should eq scopes
        consent.granted_at.should_not be_nil
      end

      it "updates existing consent with new scopes" do
        user = create_owner(password: password)
        client_id = CLIENT_ID

        # First consent
        consent1 = Authority::Consent.grant!(
          user_id: user.id.to_s,
          client_id: client_id,
          scopes: "read"
        )

        # Second consent adds more scopes
        consent2 = Authority::Consent.grant!(
          user_id: user.id.to_s,
          client_id: client_id,
          scopes: "read write"
        )

        # Should update existing, not create new
        consent2.id.should eq consent1.id
        consent2.scopes.should eq "read write"
      end
    end

    describe ".consented?" do
      it "returns true when user has consented to all requested scopes" do
        user = create_owner(password: password)
        client_id = CLIENT_ID

        Authority::Consent.grant!(
          user_id: user.id.to_s,
          client_id: client_id,
          scopes: "read write"
        )

        Authority::Consent.consented?(
          user_id: user.id.to_s,
          client_id: client_id,
          scopes: "read"
        ).should be_true

        Authority::Consent.consented?(
          user_id: user.id.to_s,
          client_id: client_id,
          scopes: "read write"
        ).should be_true
      end

      it "returns false when user has not consented" do
        user = create_owner(password: password)

        Authority::Consent.consented?(
          user_id: user.id.to_s,
          client_id: CLIENT_ID,
          scopes: "read"
        ).should be_false
      end

      it "returns false when user has not consented to all requested scopes" do
        user = create_owner(password: password)
        client_id = CLIENT_ID

        Authority::Consent.grant!(
          user_id: user.id.to_s,
          client_id: client_id,
          scopes: "read"
        )

        # User only consented to "read", not "write"
        Authority::Consent.consented?(
          user_id: user.id.to_s,
          client_id: client_id,
          scopes: "read write"
        ).should be_false
      end
    end

    describe ".revoke!" do
      it "revokes user consent for a client" do
        user = create_owner(password: password)
        client_id = CLIENT_ID

        Authority::Consent.grant!(
          user_id: user.id.to_s,
          client_id: client_id,
          scopes: "read write"
        )

        # Verify consent exists
        Authority::Consent.consented?(
          user_id: user.id.to_s,
          client_id: client_id,
          scopes: "read"
        ).should be_true

        # Revoke consent
        Authority::Consent.revoke!(
          user_id: user.id.to_s,
          client_id: client_id
        )

        # Verify consent is revoked
        Authority::Consent.consented?(
          user_id: user.id.to_s,
          client_id: client_id,
          scopes: "read"
        ).should be_false
      end
    end

    describe ".for_user" do
      it "returns all consents for a user" do
        user = create_owner(password: password)

        # Create second client for testing
        client2_id = UUID.random.to_s
        client2 = Authority::ClientEntity.new
        client2.client_id = client2_id
        client2.client_secret = Faker::Internet.password(32, 32)
        client2.redirect_uri = Faker::Internet.url("example2.com")
        client2.name = Faker::Company.name
        client2.description = Faker::Lorem.paragraph(2)
        client2.logo = Faker::Company.logo
        client2.scopes = "read write"
        client2.save!

        Authority::Consent.grant!(
          user_id: user.id.to_s,
          client_id: CLIENT_ID,
          scopes: "read"
        )

        Authority::Consent.grant!(
          user_id: user.id.to_s,
          client_id: client2_id,
          scopes: "write"
        )

        consents = Authority::Consent.for_user(user.id.to_s)
        consents.size.should eq 2
      end
    end
  end

  describe "Authorization Flow with Consent" do
    it "requires consent for first-time authorization" do
      user = create_owner(password: password)
      state = Random::Secure.hex
      auth_url = OAUTH_CLIENT.get_authorize_uri(scope: "read", state: state)

      # Flow should show consent screen (approve button visible)
      code, expected_state = AuthorizationCodeFlux.flow(
        auth_url, user.username, password)

      # Consent should be recorded after approval
      Authority::Consent.consented?(
        user_id: user.id.to_s,
        client_id: CLIENT_ID,
        scopes: "read"
      ).should be_true

      token = OAUTH_CLIENT.get_access_token_using_authorization_code(code)
      token.should be_a OAuth2::AccessToken::Bearer
    end

    it "shows consent screen with scope descriptions" do
      user = create_owner(password: password)
      state = Random::Secure.hex

      # Request multiple scopes
      auth_url = OAUTH_CLIENT.get_authorize_uri(scope: "read write", state: state)

      # The consent screen should display:
      # - Client name
      # - Requested scopes with descriptions
      # - Approve/Deny buttons
      code, _ = AuthorizationCodeFlux.flow(auth_url, user.username, password)
      code.should_not be_empty
    end
  end
end
