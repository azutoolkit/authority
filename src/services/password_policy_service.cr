# Password Policy Service
# Validates passwords against configurable security requirements.
module Authority
  module PasswordPolicyService
    extend self

    # Result struct for password validation
    struct ValidationResult
      getter? valid : Bool
      getter errors : Array(String)
      getter strength : Int32 # 0-100 strength score

      def initialize(@valid : Bool, @errors : Array(String) = [] of String, @strength : Int32 = 0)
      end

      def self.success(strength : Int32 = 100)
        new(valid: true, strength: strength)
      end

      def self.failure(errors : Array(String), strength : Int32 = 0)
        new(valid: false, errors: errors, strength: strength)
      end
    end

    # Validate a password against all policy requirements
    def validate(password : String, user : User? = nil) : ValidationResult
      errors = [] of String
      strength = 0

      strength += check_length(password, errors)
      strength += check_uppercase(password, errors)
      strength += check_lowercase(password, errors)
      strength += check_number(password, errors)
      strength += check_special_character(password, errors)
      strength += check_password_history(password, user, errors)
      strength += check_common_password(password, errors)
      strength += check_username_email(password, user, errors)
      strength += check_bonus_length(password)

      strength = [strength, 100].min

      if errors.empty?
        ValidationResult.success(strength)
      else
        ValidationResult.failure(errors, strength)
      end
    end

    # Check minimum password length
    private def check_length(password : String, errors : Array(String)) : Int32
      if password.size < Security.password_min_length
        errors << "Password must be at least #{Security.password_min_length} characters"
        0
      else
        [password.size * 2, 30].min
      end
    end

    # Check for uppercase letter requirement
    private def check_uppercase(password : String, errors : Array(String)) : Int32
      return 0 unless Security.password_require_uppercase?

      if password.matches?(/[A-Z]/)
        15
      else
        errors << "Password must contain at least one uppercase letter"
        0
      end
    end

    # Check for lowercase letter requirement
    private def check_lowercase(password : String, errors : Array(String)) : Int32
      return 0 unless Security.password_require_lowercase?

      if password.matches?(/[a-z]/)
        15
      else
        errors << "Password must contain at least one lowercase letter"
        0
      end
    end

    # Check for number requirement
    private def check_number(password : String, errors : Array(String)) : Int32
      return 0 unless Security.password_require_number?

      if password.matches?(/[0-9]/)
        15
      else
        errors << "Password must contain at least one number"
        0
      end
    end

    # Check for special character requirement
    private def check_special_character(password : String, errors : Array(String)) : Int32
      return 0 unless Security.password_require_special?

      if password.matches?(/[!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?~`]/)
        15
      else
        errors << "Password must contain at least one special character (!@#$%^&*...)"
        0
      end
    end

    # Check against password history
    private def check_password_history(password : String, user : User?, errors : Array(String)) : Int32
      return 0 unless user && Security.password_history_count > 0

      if in_password_history?(password, user)
        errors << "Password cannot be one of your last #{Security.password_history_count} passwords"
      end
      0
    end

    # Check if password is common and apply penalty
    private def check_common_password(password : String, errors : Array(String)) : Int32
      if common_password?(password)
        errors << "Password is too common, please choose a more unique password"
        -30
      else
        0
      end
    end

    # Check if password contains username or email
    private def check_username_email(password : String, user : User?, errors : Array(String)) : Int32
      return 0 unless user

      password_lower = password.downcase
      username_lower = user.username.downcase
      email_local = user.email.split("@").first.downcase

      if password_lower.includes?(username_lower) || password_lower.includes?(email_local)
        errors << "Password cannot contain your username or email"
        -20
      else
        0
      end
    end

    # Bonus points for extra length
    private def check_bonus_length(password : String) : Int32
      password.size >= 16 ? 10 : 0
    end

    # Check if password is in the user's history
    def in_password_history?(password : String, user : User) : Bool
      history = user.password_history
      return false if history.nil? || history.empty?

      # Parse the stored history (JSON array of bcrypt hashes)
      begin
        hashes = Array(String).from_json(history)
        hashes.any? do |hash|
          Crypto::Bcrypt::Password.new(hash).verify(password)
        end
      rescue
        false
      end
    end

    # Add a password to the user's history
    def add_to_history(user : User, encrypted_password : String) : String
      history = user.password_history
      hashes = if history.nil? || history.empty?
                 [] of String
               else
                 begin
                   Array(String).from_json(history)
                 rescue
                   [] of String
                 end
               end

      # Add the new password to the front
      hashes.unshift(encrypted_password)

      # Keep only the last N passwords
      if hashes.size > Security.password_history_count
        hashes = hashes.first(Security.password_history_count)
      end

      hashes.to_json
    end

    # Check if password has expired
    def password_expired?(user : User) : Bool
      return false if Security.password_expiry_days <= 0

      if changed_at = user.password_changed_at
        expiry_date = changed_at + Security.password_expiry_days.days
        Time.utc > expiry_date
      else
        true
      end
    end

    # Get days until password expiry
    def days_until_expiry(user : User) : Int32?
      return nil if Security.password_expiry_days <= 0

      if changed_at = user.password_changed_at
        expiry_date = changed_at + Security.password_expiry_days.days
        remaining = (expiry_date - Time.utc).total_days.to_i
        [remaining, 0].max
      else
        0
      end
    end

    # Check if password is in the list of common passwords
    private def common_password?(password : String) : Bool
      COMMON_PASSWORDS.includes?(password.downcase)
    end

    # List of common passwords to reject
    COMMON_PASSWORDS = Set{
      "password", "123456", "12345678", "qwerty", "abc123", "monkey", "1234567",
      "letmein", "trustno1", "dragon", "baseball", "iloveyou", "master", "sunshine",
      "ashley", "bailey", "shadow", "123123", "654321", "superman", "qazwsx",
      "michael", "football", "password1", "password123", "welcome", "welcome1",
      "admin", "admin123", "root", "toor", "pass", "test", "guest", "master",
      "changeme", "12345", "1234", "111111", "000000", "passw0rd", "pa$$word",
      "p@ssword", "p@ssw0rd", "secret", "login", "administrator",
    }

    # Generate a secure random password
    def generate_password(length : Int32 = 16) : String
      chars = "ABCDEFGHJKLMNPQRSTUVWXYZabcdefghjkmnpqrstuvwxyz23456789!@#$%^&*"
      password = String.build do |str|
        length.times do
          str << chars[Random::Secure.rand(chars.size)]
        end
      end

      # Ensure it meets requirements
      result = validate(password)
      if result.valid?
        password
      else
        # Recursively generate until we get a valid one
        generate_password(length)
      end
    end

    # Get human-readable password requirements
    def requirements : Array(String)
      reqs = [] of String
      reqs << "At least #{Security.password_min_length} characters"
      reqs << "At least one uppercase letter (A-Z)" if Security.password_require_uppercase?
      reqs << "At least one lowercase letter (a-z)" if Security.password_require_lowercase?
      reqs << "At least one number (0-9)" if Security.password_require_number?
      reqs << "At least one special character (!@#$%^&*...)" if Security.password_require_special?
      reqs << "Cannot be one of your last #{Security.password_history_count} passwords" if Security.password_history_count > 0
      reqs << "Cannot be a commonly used password"
      reqs
    end
  end
end
