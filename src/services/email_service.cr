require "email"

module Authority
  # EmailService handles sending transactional emails for authentication events.
  # Supports password reset, email verification, account lockout notifications, etc.
  module EmailService
    extend self

    # Result struct for email operations
    struct Result
      getter? success : Bool
      getter error : String?
      getter message_id : String?

      def initialize(@success : Bool, @error : String? = nil, @message_id : String? = nil)
      end
    end

    # Email types for tracking and templates
    enum EmailType
      PasswordReset
      EmailVerification
      AccountLocked
      AccountUnlocked
      Welcome
      PasswordChanged
      MFAEnabled
      MFADisabled
    end

    # Send a password reset email
    def send_password_reset(to_email : String, to_name : String, reset_token : String, expires_at : Time) : Result
      return Result.new(success: false, error: "Email not configured") unless Email.configured?
      return Result.new(success: false, error: "Password reset emails disabled") unless Email.send_password_reset

      reset_url = "#{Email.app_url}/password/reset?token=#{reset_token}"
      expires_in = format_duration(expires_at - Time.utc)

      subject = "Reset Your #{Email.app_name} Password"
      html_body = render_template("password_reset", {
        "name"       => to_name,
        "reset_url"  => reset_url,
        "expires_in" => expires_in,
        "app_name"   => Email.app_name,
        "support_email" => Email.support_email,
      })

      text_body = <<-TEXT
      Hi #{to_name},

      You requested a password reset for your #{Email.app_name} account.

      Click the link below to reset your password:
      #{reset_url}

      This link will expire in #{expires_in}.

      If you didn't request this, you can safely ignore this email.

      - The #{Email.app_name} Team
      TEXT

      send_email(to_email, to_name, subject, html_body, text_body)
    end

    # Send an email verification email
    def send_email_verification(to_email : String, to_name : String, verification_token : String, expires_at : Time) : Result
      return Result.new(success: false, error: "Email not configured") unless Email.configured?
      return Result.new(success: false, error: "Email verification emails disabled") unless Email.send_email_verification

      verify_url = "#{Email.app_url}/verify-email?token=#{verification_token}"
      expires_in = format_duration(expires_at - Time.utc)

      subject = "Verify Your #{Email.app_name} Email Address"
      html_body = render_template("email_verification", {
        "name"       => to_name,
        "verify_url" => verify_url,
        "expires_in" => expires_in,
        "app_name"   => Email.app_name,
        "support_email" => Email.support_email,
      })

      text_body = <<-TEXT
      Hi #{to_name},

      Please verify your email address for your #{Email.app_name} account.

      Click the link below to verify:
      #{verify_url}

      This link will expire in #{expires_in}.

      - The #{Email.app_name} Team
      TEXT

      send_email(to_email, to_name, subject, html_body, text_body)
    end

    # Send an account locked notification
    def send_account_locked(to_email : String, to_name : String, reason : String, unlock_at : Time?) : Result
      return Result.new(success: false, error: "Email not configured") unless Email.configured?
      return Result.new(success: false, error: "Lockout notification emails disabled") unless Email.send_lockout_notification

      unlock_info = if unlock_at
                      "Your account will be automatically unlocked in #{format_duration(unlock_at - Time.utc)}."
                    else
                      "Please contact support to unlock your account."
                    end

      subject = "#{Email.app_name} Account Locked"
      html_body = render_template("account_locked", {
        "name"        => to_name,
        "reason"      => reason,
        "unlock_info" => unlock_info,
        "app_name"    => Email.app_name,
        "support_email" => Email.support_email,
      })

      text_body = <<-TEXT
      Hi #{to_name},

      Your #{Email.app_name} account has been locked.

      Reason: #{reason}

      #{unlock_info}

      If you believe this is an error, please contact #{Email.support_email}.

      - The #{Email.app_name} Team
      TEXT

      send_email(to_email, to_name, subject, html_body, text_body)
    end

    # Send an account unlocked notification
    def send_account_unlocked(to_email : String, to_name : String) : Result
      return Result.new(success: false, error: "Email not configured") unless Email.configured?
      return Result.new(success: false, error: "Lockout notification emails disabled") unless Email.send_lockout_notification

      login_url = "#{Email.app_url}/signin"

      subject = "#{Email.app_name} Account Unlocked"
      html_body = render_template("account_unlocked", {
        "name"      => to_name,
        "login_url" => login_url,
        "app_name"  => Email.app_name,
        "support_email" => Email.support_email,
      })

      text_body = <<-TEXT
      Hi #{to_name},

      Your #{Email.app_name} account has been unlocked.

      You can now sign in at: #{login_url}

      If you have any concerns, please contact #{Email.support_email}.

      - The #{Email.app_name} Team
      TEXT

      send_email(to_email, to_name, subject, html_body, text_body)
    end

    # Send a welcome email
    def send_welcome(to_email : String, to_name : String) : Result
      return Result.new(success: false, error: "Email not configured") unless Email.configured?
      return Result.new(success: false, error: "Welcome emails disabled") unless Email.send_welcome_email

      login_url = "#{Email.app_url}/signin"

      subject = "Welcome to #{Email.app_name}"
      html_body = render_template("welcome", {
        "name"      => to_name,
        "login_url" => login_url,
        "app_name"  => Email.app_name,
        "support_email" => Email.support_email,
      })

      text_body = <<-TEXT
      Hi #{to_name},

      Welcome to #{Email.app_name}!

      Your account has been created. You can sign in at:
      #{login_url}

      If you have any questions, contact #{Email.support_email}.

      - The #{Email.app_name} Team
      TEXT

      send_email(to_email, to_name, subject, html_body, text_body)
    end

    # Send a password changed notification
    def send_password_changed(to_email : String, to_name : String) : Result
      return Result.new(success: false, error: "Email not configured") unless Email.configured?

      subject = "#{Email.app_name} Password Changed"
      html_body = render_template("password_changed", {
        "name"     => to_name,
        "app_name" => Email.app_name,
        "support_email" => Email.support_email,
      })

      text_body = <<-TEXT
      Hi #{to_name},

      Your #{Email.app_name} password has been changed.

      If you did not make this change, please contact #{Email.support_email} immediately.

      - The #{Email.app_name} Team
      TEXT

      send_email(to_email, to_name, subject, html_body, text_body)
    end

    # Core email sending function
    private def send_email(to_email : String, to_name : String, subject : String, html_body : String, text_body : String) : Result
      return Result.new(success: false, error: "Email not configured") unless Email.configured?

      message = EMail::Message.new
      message.from Email.from_address, Email.from_name
      message.to to_email, to_name
      message.subject subject
      message.message text_body
      message.message_html html_body

      # Extract domain from from_address for HELO command
      helo_domain = Email.from_address.split("@").last? || "localhost"
      config = EMail::Client::Config.new(Email.smtp_host, Email.smtp_port, helo_domain: helo_domain)

      if Email.smtp_tls
        config.use_tls(EMail::Client::TLSMode::STARTTLS)
      end

      if !Email.smtp_username.empty?
        config.use_auth(Email.smtp_username, Email.smtp_password)
      end

      client = EMail::Client.new(config)
      client.start do
        send(message)
      end

      Log.info { "Email sent successfully to #{to_email}: #{subject}" }
      Result.new(success: true, message_id: "sent")
    rescue ex
      Log.error { "Failed to send email to #{to_email}: #{ex.message}" }
      Result.new(success: false, error: ex.message)
    end

    # Render an email template with variables
    private def render_template(template_name : String, vars : Hash(String, String)) : String
      # Try to load template from file
      template_path = "public/templates/emails/#{template_name}.html"

      if File.exists?(template_path)
        content = File.read(template_path)
        vars.each do |key, value|
          content = content.gsub("{{#{key}}}", value)
        end
        content
      else
        # Fallback to inline template
        generate_default_template(template_name, vars)
      end
    end

    # Generate a default template if file doesn't exist
    private def generate_default_template(template_name : String, vars : Hash(String, String)) : String
      app_name = vars["app_name"]? || "Authority"
      name = vars["name"]? || "User"

      <<-HTML
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <style>
          body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; line-height: 1.6; color: #333; max-width: 600px; margin: 0 auto; padding: 20px; }
          .header { background: #4f46e5; color: white; padding: 20px; text-align: center; border-radius: 8px 8px 0 0; }
          .content { background: #f9fafb; padding: 30px; border: 1px solid #e5e7eb; }
          .button { display: inline-block; background: #4f46e5; color: white; padding: 12px 24px; text-decoration: none; border-radius: 6px; margin: 20px 0; }
          .footer { text-align: center; padding: 20px; color: #6b7280; font-size: 14px; }
        </style>
      </head>
      <body>
        <div class="header">
          <h1>#{app_name}</h1>
        </div>
        <div class="content">
          <p>Hi #{name},</p>
          #{generate_template_content(template_name, vars)}
        </div>
        <div class="footer">
          <p>© #{Time.utc.year} #{app_name}. All rights reserved.</p>
        </div>
      </body>
      </html>
      HTML
    end

    private def generate_template_content(template_name : String, vars : Hash(String, String)) : String
      case template_name
      when "password_reset"
        url = vars["reset_url"]? || "#"
        expires = vars["expires_in"]? || "24 hours"
        <<-HTML
        <p>You requested a password reset for your account.</p>
        <p><a href="#{url}" class="button">Reset Password</a></p>
        <p>Or copy this link: #{url}</p>
        <p>This link will expire in #{expires}.</p>
        <p>If you didn't request this, you can safely ignore this email.</p>
        HTML
      when "email_verification"
        url = vars["verify_url"]? || "#"
        expires = vars["expires_in"]? || "24 hours"
        <<-HTML
        <p>Please verify your email address to complete your account setup.</p>
        <p><a href="#{url}" class="button">Verify Email</a></p>
        <p>Or copy this link: #{url}</p>
        <p>This link will expire in #{expires}.</p>
        HTML
      when "account_locked"
        reason = vars["reason"]? || "Too many failed login attempts"
        unlock_info = vars["unlock_info"]? || "Please contact support."
        <<-HTML
        <p>Your account has been locked.</p>
        <p><strong>Reason:</strong> #{reason}</p>
        <p>#{unlock_info}</p>
        <p>If you believe this is an error, please contact support.</p>
        HTML
      when "account_unlocked"
        url = vars["login_url"]? || "#"
        <<-HTML
        <p>Your account has been unlocked.</p>
        <p>You can now sign in to your account.</p>
        <p><a href="#{url}" class="button">Sign In</a></p>
        HTML
      when "welcome"
        url = vars["login_url"]? || "#"
        <<-HTML
        <p>Welcome! Your account has been created successfully.</p>
        <p><a href="#{url}" class="button">Sign In</a></p>
        HTML
      when "password_changed"
        <<-HTML
        <p>Your password has been changed.</p>
        <p>If you did not make this change, please contact support immediately.</p>
        HTML
      else
        "<p>This is an automated message from your account.</p>"
      end
    end

    private def format_duration(span : Time::Span) : String
      total_seconds = span.total_seconds.to_i
      return "a few seconds" if total_seconds < 60

      if total_seconds >= 86400
        days = total_seconds // 86400
        "#{days} day#{"s" if days > 1}"
      elsif total_seconds >= 3600
        hours = total_seconds // 3600
        "#{hours} hour#{"s" if hours > 1}"
      else
        minutes = total_seconds // 60
        "#{minutes} minute#{"s" if minutes > 1}"
      end
    end
  end
end
