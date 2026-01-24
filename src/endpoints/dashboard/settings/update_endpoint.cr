# Endpoint for Admin Settings Update
# POST /dashboard/settings - Update system settings
module Authority::Dashboard::Settings
  class UpdateEndpoint
    include SessionHelper
    include SecurityHeadersHelper
    include AdminAuthHelper
    include Endpoint(UpdateRequest, IndexResponse | Response)

    post "/dashboard/settings"

    def call : IndexResponse | Response
      set_security_headers!
      header "Content-Type", "text/html; charset=UTF-8"
      header "Cache-Control", "no-store"
      header "Pragma", "no-cache"

      # Check admin authorization
      if auth_error = require_admin!
        return auth_error
      end

      admin_user = current_admin_user
      return forbidden_response("Admin access required") unless admin_user

      # Check for super_admin scope
      unless RBACService.has_scope?(admin_user, "authority:super_admin")
        return forbidden_response("Super admin access required for settings")
      end

      tab = update_request.tab
      errors = [] of String

      case tab
      when "security"
        update_security_settings(admin_user.username, errors)
      when "email"
        update_email_settings(admin_user.username, errors)
      when "audit"
        update_audit_settings(admin_user.username, errors)
      when "branding"
        update_branding_settings(admin_user.username, errors)
      when "social"
        update_social_settings(admin_user.username, errors)
      end

      # Log audit
      AuditService.log(
        actor: admin_user,
        action: "update_settings",
        resource_type: "settings",
        resource_id: tab,
        resource_name: "#{tab} settings"
      )

      # Get updated settings
      settings = SettingsService.get_all_grouped

      if errors.empty?
        IndexResponse.new(
          settings: settings,
          active_tab: tab,
          username: admin_user.username,
          success: "Settings updated successfully"
        )
      else
        IndexResponse.new(
          settings: settings,
          active_tab: tab,
          username: admin_user.username,
          errors: errors
        )
      end
    end

    private def update_security_settings(updated_by : String, errors : Array(String))
      set_if_present(Setting::Keys::LOCKOUT_THRESHOLD, update_request.lockout_threshold, Setting::Categories::SECURITY, updated_by, errors)
      set_if_present(Setting::Keys::LOCKOUT_DURATION_MINUTES, update_request.lockout_duration_minutes, Setting::Categories::SECURITY, updated_by, errors)
      set_checkbox(Setting::Keys::AUTO_UNLOCK_ENABLED, update_request.auto_unlock_enabled, Setting::Categories::SECURITY, updated_by)
      set_if_present(Setting::Keys::SESSION_DURATION_DAYS, update_request.session_duration_days, Setting::Categories::SECURITY, updated_by, errors)
      set_if_present(Setting::Keys::PASSWORD_MIN_LENGTH, update_request.password_min_length, Setting::Categories::SECURITY, updated_by, errors)
      set_checkbox(Setting::Keys::PASSWORD_REQUIRE_UPPERCASE, update_request.password_require_uppercase, Setting::Categories::SECURITY, updated_by)
      set_checkbox(Setting::Keys::PASSWORD_REQUIRE_LOWERCASE, update_request.password_require_lowercase, Setting::Categories::SECURITY, updated_by)
      set_checkbox(Setting::Keys::PASSWORD_REQUIRE_NUMBER, update_request.password_require_number, Setting::Categories::SECURITY, updated_by)
      set_checkbox(Setting::Keys::PASSWORD_REQUIRE_SPECIAL, update_request.password_require_special, Setting::Categories::SECURITY, updated_by)
      set_if_present(Setting::Keys::PASSWORD_HISTORY_COUNT, update_request.password_history_count, Setting::Categories::SECURITY, updated_by, errors)
    end

    private def update_email_settings(updated_by : String, errors : Array(String))
      set_checkbox(Setting::Keys::SMTP_ENABLED, update_request.smtp_enabled, Setting::Categories::EMAIL, updated_by)
      set_if_present(Setting::Keys::SMTP_HOST, update_request.smtp_host, Setting::Categories::EMAIL, updated_by, errors)
      set_if_present(Setting::Keys::SMTP_PORT, update_request.smtp_port, Setting::Categories::EMAIL, updated_by, errors)
      SettingsService.set(Setting::Keys::SMTP_USERNAME, update_request.smtp_username, Setting::Categories::EMAIL, nil, updated_by)
      set_if_present(Setting::Keys::SMTP_FROM_ADDRESS, update_request.smtp_from_address, Setting::Categories::EMAIL, updated_by, errors)
      set_if_present(Setting::Keys::SMTP_FROM_NAME, update_request.smtp_from_name, Setting::Categories::EMAIL, updated_by, errors)
    end

    private def update_audit_settings(updated_by : String, errors : Array(String))
      set_if_present(Setting::Keys::AUDIT_RETENTION_DAYS, update_request.audit_retention_days, Setting::Categories::AUDIT, updated_by, errors)
      set_if_present(Setting::Keys::AUDIT_LOG_LEVEL, update_request.audit_log_level, Setting::Categories::AUDIT, updated_by, errors)
    end

    private def update_branding_settings(updated_by : String, errors : Array(String))
      set_if_present(Setting::Keys::APP_NAME, update_request.app_name, Setting::Categories::BRANDING, updated_by, errors)
      SettingsService.set(Setting::Keys::APP_LOGO_URL, update_request.app_logo_url, Setting::Categories::BRANDING, nil, updated_by)
      set_if_present(Setting::Keys::PRIMARY_COLOR, update_request.primary_color, Setting::Categories::BRANDING, updated_by, errors)
      SettingsService.set(Setting::Keys::SUPPORT_EMAIL, update_request.support_email, Setting::Categories::BRANDING, nil, updated_by)
    end

    private def update_social_settings(updated_by : String, errors : Array(String))
      # Google
      set_checkbox(Setting::Keys::GOOGLE_OAUTH_ENABLED, update_request.google_oauth_enabled, Setting::Categories::SOCIAL, updated_by)
      SettingsService.set(Setting::Keys::GOOGLE_CLIENT_ID, update_request.google_client_id, Setting::Categories::SOCIAL, nil, updated_by)
      SettingsService.set(Setting::Keys::GOOGLE_CLIENT_SECRET, update_request.google_client_secret, Setting::Categories::SOCIAL, nil, updated_by)

      # Facebook
      set_checkbox(Setting::Keys::FACEBOOK_OAUTH_ENABLED, update_request.facebook_oauth_enabled, Setting::Categories::SOCIAL, updated_by)
      SettingsService.set(Setting::Keys::FACEBOOK_CLIENT_ID, update_request.facebook_client_id, Setting::Categories::SOCIAL, nil, updated_by)
      SettingsService.set(Setting::Keys::FACEBOOK_CLIENT_SECRET, update_request.facebook_client_secret, Setting::Categories::SOCIAL, nil, updated_by)

      # Apple
      set_checkbox(Setting::Keys::APPLE_OAUTH_ENABLED, update_request.apple_oauth_enabled, Setting::Categories::SOCIAL, updated_by)
      SettingsService.set(Setting::Keys::APPLE_CLIENT_ID, update_request.apple_client_id, Setting::Categories::SOCIAL, nil, updated_by)
      SettingsService.set(Setting::Keys::APPLE_TEAM_ID, update_request.apple_team_id, Setting::Categories::SOCIAL, nil, updated_by)
      SettingsService.set(Setting::Keys::APPLE_KEY_ID, update_request.apple_key_id, Setting::Categories::SOCIAL, nil, updated_by)
      SettingsService.set(Setting::Keys::APPLE_PRIVATE_KEY, update_request.apple_private_key, Setting::Categories::SOCIAL, nil, updated_by)

      # LinkedIn
      set_checkbox(Setting::Keys::LINKEDIN_OAUTH_ENABLED, update_request.linkedin_oauth_enabled, Setting::Categories::SOCIAL, updated_by)
      SettingsService.set(Setting::Keys::LINKEDIN_CLIENT_ID, update_request.linkedin_client_id, Setting::Categories::SOCIAL, nil, updated_by)
      SettingsService.set(Setting::Keys::LINKEDIN_CLIENT_SECRET, update_request.linkedin_client_secret, Setting::Categories::SOCIAL, nil, updated_by)

      # GitHub
      set_checkbox(Setting::Keys::GITHUB_OAUTH_ENABLED, update_request.github_oauth_enabled, Setting::Categories::SOCIAL, updated_by)
      SettingsService.set(Setting::Keys::GITHUB_CLIENT_ID, update_request.github_client_id, Setting::Categories::SOCIAL, nil, updated_by)
      SettingsService.set(Setting::Keys::GITHUB_CLIENT_SECRET, update_request.github_client_secret, Setting::Categories::SOCIAL, nil, updated_by)
    end

    private def set_if_present(key : String, value : String, category : String, updated_by : String, errors : Array(String))
      return if value.empty?
      result = SettingsService.set(key, value, category, nil, updated_by)
      errors << "Failed to update #{key}: #{result.error}" unless result.success?
    end

    private def set_checkbox(key : String, value : String, category : String, updated_by : String)
      # Checkbox is "on" when checked, empty when not
      bool_value = value == "on" ? "true" : "false"
      SettingsService.set(key, bool_value, category, nil, updated_by)
    end
  end
end
