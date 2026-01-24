# Admin Settings Update Request
module Authority::Dashboard::Settings
  struct UpdateRequest
    include Request

    getter tab : String = "security"

    # Security settings
    getter lockout_threshold : String = ""
    getter lockout_duration_minutes : String = ""
    getter auto_unlock_enabled : String = ""
    getter session_duration_days : String = ""
    getter password_min_length : String = ""
    getter password_require_uppercase : String = ""
    getter password_require_lowercase : String = ""
    getter password_require_number : String = ""
    getter password_require_special : String = ""
    getter password_history_count : String = ""

    # Email settings
    getter smtp_enabled : String = ""
    getter smtp_host : String = ""
    getter smtp_port : String = ""
    getter smtp_username : String = ""
    getter smtp_from_address : String = ""
    getter smtp_from_name : String = ""

    # Audit settings
    getter audit_retention_days : String = ""
    getter audit_log_level : String = ""

    # Branding settings
    getter app_name : String = ""
    getter app_logo_url : String = ""
    getter primary_color : String = ""
    getter support_email : String = ""

    # Social Login - Google
    getter google_oauth_enabled : String = ""
    getter google_client_id : String = ""
    getter google_client_secret : String = ""

    # Social Login - Facebook
    getter facebook_oauth_enabled : String = ""
    getter facebook_client_id : String = ""
    getter facebook_client_secret : String = ""

    # Social Login - Apple
    getter apple_oauth_enabled : String = ""
    getter apple_client_id : String = ""
    getter apple_team_id : String = ""
    getter apple_key_id : String = ""
    getter apple_private_key : String = ""

    # Social Login - LinkedIn
    getter linkedin_oauth_enabled : String = ""
    getter linkedin_client_id : String = ""
    getter linkedin_client_secret : String = ""

    # Social Login - GitHub
    getter github_oauth_enabled : String = ""
    getter github_client_id : String = ""
    getter github_client_secret : String = ""
  end
end
