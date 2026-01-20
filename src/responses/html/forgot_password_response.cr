# Response for Forgot Password page
module Authority::Account
  # Forgot Password Form Response
  struct ForgotPasswordFormResponse
    include Response
    include Templates::Renderable

    TEMPLATE = "forgot_password_form.html"

    def initialize(@email : String = "", @errors : Array(String)? = nil)
    end

    def render
      view TEMPLATE, {
        email:  @email,
        errors: @errors,
      }
    end
  end

  # Forgot Password Sent Response
  struct ForgotPasswordSentResponse
    include Response
    include Templates::Renderable

    TEMPLATE = "forgot_password_sent.html"

    def initialize(@email : String)
    end

    def render
      view TEMPLATE, {
        email: @email,
      }
    end
  end

  # Reset Password Form Response
  struct ResetPasswordFormResponse
    include Response
    include Templates::Renderable

    TEMPLATE = "reset_password_form.html"

    def initialize(@token : String, @errors : Array(String)? = nil)
    end

    def render
      view TEMPLATE, {
        token:  @token,
        errors: @errors,
      }
    end
  end

  # Reset Password Success Response
  struct ResetPasswordSuccessResponse
    include Response
    include Templates::Renderable

    TEMPLATE = "reset_password_success.html"

    def initialize
    end

    def render
      view TEMPLATE, {} of String => String
    end
  end
end
