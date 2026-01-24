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
  end
end
