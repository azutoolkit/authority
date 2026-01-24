# Response for MFA Setup page
module Authority::MFA
  struct SetupResponse
    include Response
    include Templates::Renderable

    TEMPLATE = "auth/mfa/setup.html"

    def initialize(
      @username : String,
      @secret : String,
      @qr_uri : String,
      @backup_codes : Array(String),
      @errors : Array(String)? = nil
    )
    end

    def render
      view TEMPLATE, {
        username:     @username,
        secret:       @secret,
        qr_uri:       @qr_uri,
        backup_codes: @backup_codes,
        errors:       @errors,
      }
    end
  end

  struct VerifyResponse
    include Response
    include Templates::Renderable

    TEMPLATE = "auth/mfa/verify.html"

    def initialize(
      @username : String,
      @forward_url : String = "",
      @backup_codes_remaining : Int32 = 0,
      @errors : Array(String)? = nil
    )
    end

    def render
      view TEMPLATE, {
        username:               @username,
        forward_url:            @forward_url,
        backup_codes_remaining: @backup_codes_remaining,
        errors:                 @errors,
      }
    end
  end

  struct DisableResponse
    include Response
    include Templates::Renderable

    TEMPLATE = "auth/mfa/disable.html"

    def initialize(
      @username : String,
      @errors : Array(String)? = nil
    )
    end

    def render
      view TEMPLATE, {
        username: @username,
        errors:   @errors,
      }
    end
  end
end
