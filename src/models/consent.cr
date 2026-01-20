# User Consent Model
# Stores user consent for OAuth2 scope grants per client
# Enables explicit user approval and consent management
module Authority
  class Consent
    include CQL::ActiveRecord::Model(UUID)
    db_context AuthorityDB, :oauth_consents

    property user_id : String = ""
    property client_id : String = ""
    property scopes : String = ""
    property granted_at : Time = Time.utc
    property revoked_at : Time?
    property created_at : Time?
    property updated_at : Time?

    def initialize
    end

    # Check if consent is active (not revoked)
    def active? : Bool
      revoked_at.nil?
    end

    # Check if consent includes all requested scopes
    def includes_scopes?(requested_scopes : String) : Bool
      return false unless active?

      granted_set = scopes.split(/[\s,]+/).to_set
      requested_set = requested_scopes.split(/[\s,]+/).to_set

      requested_set.subset_of?(granted_set)
    end

    # Revoke this consent
    def revoke!
      @revoked_at = Time.utc
      update!
    end

    # Grant consent for a user to a client with specific scopes
    # Updates existing consent if one exists
    def self.grant!(user_id : String, client_id : String, scopes : String) : Consent
      existing = find_by(user_id: user_id, client_id: client_id)

      if existing
        # Merge scopes - combine existing and new scopes
        existing_set = existing.scopes.split(/[\s,]+/).to_set
        new_set = scopes.split(/[\s,]+/).to_set
        merged = (existing_set | new_set).join(" ")

        existing.scopes = merged
        existing.granted_at = Time.utc
        existing.revoked_at = nil  # Reactivate if revoked
        existing.update!
        existing
      else
        consent = Consent.new
        consent.user_id = user_id
        consent.client_id = client_id
        consent.scopes = scopes
        consent.granted_at = Time.utc
        consent.save!
        consent
      end
    end

    # Check if user has consented to the requested scopes for this client
    def self.consented?(user_id : String, client_id : String, scopes : String) : Bool
      consent = find_by(user_id: user_id, client_id: client_id)
      return false unless consent

      consent.includes_scopes?(scopes)
    end

    # Revoke consent for a user to a client
    def self.revoke!(user_id : String, client_id : String) : Bool
      consent = find_by(user_id: user_id, client_id: client_id)
      return false unless consent

      consent.revoke!
      true
    end

    # Get all consents for a user
    def self.for_user(user_id : String) : Array(Consent)
      results = [] of Consent
      where(user_id: user_id).each do |consent|
        results << consent if consent.active?
      end
      results
    end

    # Get all consents for a client
    def self.for_client(client_id : String) : Array(Consent)
      results = [] of Consent
      where(client_id: client_id).each do |consent|
        results << consent if consent.active?
      end
      results
    end

    # Revoke all consents for a user (logout from all apps)
    def self.revoke_all_for_user!(user_id : String)
      where(user_id: user_id).each do |consent|
        consent.revoke! if consent.active?
      end
    end

    # Revoke all consents for a client
    def self.revoke_all_for_client!(client_id : String)
      where(client_id: client_id).each do |consent|
        consent.revoke! if consent.active?
      end
    end
  end
end
