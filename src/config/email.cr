# Email configuration for notifications and transactional emails
module Authority
  class Email
    # SMTP settings
    class_property smtp_enabled : Bool = ENV.fetch("SMTP_ENABLED", "false") == "true"
    class_property smtp_host : String = ENV.fetch("SMTP_HOST", "localhost")
    class_property smtp_port : Int32 = ENV.fetch("SMTP_PORT", "587").to_i
    class_property smtp_username : String = ENV.fetch("SMTP_USERNAME", "")
    class_property smtp_password : String = ENV.fetch("SMTP_PASSWORD", "")
    class_property smtp_tls : Bool = ENV.fetch("SMTP_TLS", "true") == "true"
    class_property smtp_auth : String = ENV.fetch("SMTP_AUTH", "login") # login, plain, cram_md5

    # Email sender settings
    class_property from_address : String = ENV.fetch("EMAIL_FROM_ADDRESS", "noreply@authority.local")
    class_property from_name : String = ENV.fetch("EMAIL_FROM_NAME", "Authority")

    # App settings for email templates
    class_property app_name : String = ENV.fetch("APP_NAME", "Authority")
    class_property app_url : String = ENV.fetch("APP_URL", "http://localhost:4000")
    class_property support_email : String = ENV.fetch("SUPPORT_EMAIL", "support@authority.local")

    # Email features
    class_property send_lockout_notification : Bool = ENV.fetch("SEND_LOCKOUT_NOTIFICATION", "true") == "true"
    class_property send_password_reset : Bool = ENV.fetch("SEND_PASSWORD_RESET", "true") == "true"
    class_property send_email_verification : Bool = ENV.fetch("SEND_EMAIL_VERIFICATION", "true") == "true"
    class_property send_welcome_email : Bool = ENV.fetch("SEND_WELCOME_EMAIL", "false") == "true"

    # Rate limiting for emails
    class_property max_emails_per_hour : Int32 = ENV.fetch("MAX_EMAILS_PER_HOUR", "100").to_i

    # Connection check
    def self.configured? : Bool
      smtp_enabled && !smtp_host.empty?
    end
  end
end
