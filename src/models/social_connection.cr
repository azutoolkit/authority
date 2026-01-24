# SocialConnection model for storing OAuth social login provider connections.
# Links users to their social accounts (Google, Facebook, Apple, LinkedIn, GitHub).
module Authority
  @[Crinja::Attributes(expose: [id_str, provider, provider_user_id, email, name, avatar_url, created_at, updated_at])]
  class SocialConnection
    include CQL::ActiveRecord::Model(UUID)
    include Crinja::Object::Auto
    db_context AuthorityDB, :social_connections

    property user_id : UUID?
    property provider : String = ""
    property provider_user_id : String = ""
    property email : String?
    property name : String?
    property avatar_url : String?
    property access_token : String?
    property refresh_token : String?
    property token_expires_at : Time?
    property raw_info : String?
    property created_at : Time?
    property updated_at : Time?

    # Supported social providers
    module Providers
      GOOGLE   = "google"
      FACEBOOK = "facebook"
      APPLE    = "apple"
      LINKEDIN = "linkedin"
      GITHUB   = "github"

      ALL = [GOOGLE, FACEBOOK, APPLE, LINKEDIN, GITHUB]

      def self.valid?(provider : String) : Bool
        ALL.includes?(provider.downcase)
      end
    end

    def initialize
    end

    # Helper to get string ID for templates
    def id_str : String
      id.to_s
    end

    # Find a social connection by provider and provider user ID
    def self.find_by_provider(provider : String, provider_user_id : String) : SocialConnection?
      query.where(provider: provider, provider_user_id: provider_user_id).first
    end

    # Find all social connections for a user
    def self.find_by_user(user_id : UUID) : Array(SocialConnection)
      query.where(user_id: user_id.to_s).all
    end

    # Find a connection by provider and email
    def self.find_by_provider_email(provider : String, email : String) : SocialConnection?
      query.where(provider: provider, email: email).first
    end

    # Check if a user has a specific provider linked
    def self.user_has_provider?(user_id : UUID, provider : String) : Bool
      query.where(user_id: user_id.to_s, provider: provider).count > 0
    end

    # Get provider display name
    def provider_display_name : String
      case provider
      when Providers::GOOGLE   then "Google"
      when Providers::FACEBOOK then "Facebook"
      when Providers::APPLE    then "Apple"
      when Providers::LINKEDIN then "LinkedIn"
      when Providers::GITHUB   then "GitHub"
      else                          provider.capitalize
      end
    end

    # Check if token is expired
    def token_expired? : Bool
      if expires_at = token_expires_at
        Time.utc > expires_at
      else
        true
      end
    end
  end
end
