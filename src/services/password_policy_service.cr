# Password Policy Service
# Validates passwords against configurable security requirements.
module Authority
  module PasswordPolicyService
    extend self

    # Result struct for password validation
    struct ValidationResult
      getter? valid : Bool
      getter errors : Array(String)
      getter strength : Int32  # 0-100 strength score

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

      # Length check
      if password.size < Security.password_min_length
        errors << "Password must be at least #{Security.password_min_length} characters"
      else
        # Award points for length
        strength += [password.size * 2, 30].min
      end

      # Uppercase check
      if Security.password_require_uppercase
        if password.matches?(/[A-Z]/)
          strength += 15
        else
          errors << "Password must contain at least one uppercase letter"
        end
      end

      # Lowercase check
      if Security.password_require_lowercase
        if password.matches?(/[a-z]/)
          strength += 15
        else
          errors << "Password must contain at least one lowercase letter"
        end
      end

      # Number check
      if Security.password_require_number
        if password.matches?(/[0-9]/)
          strength += 15
        else
          errors << "Password must contain at least one number"
        end
      end

      # Special character check
      if Security.password_require_special
        if password.matches?(/[!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?~`]/)
          strength += 15
        else
          errors << "Password must contain at least one special character (!@#$%^&*...)"
        end
      end

      # Check against password history if user provided
      if user && Security.password_history_count > 0
        if in_password_history?(password, user)
          errors << "Password cannot be one of your last #{Security.password_history_count} passwords"
        end
      end

      # Common password check
      if common_password?(password)
        errors << "Password is too common, please choose a more unique password"
        strength = [strength - 30, 0].max
      end

      # Username/email check
      if user
        if password.downcase.includes?(user.username.downcase) ||
           password.downcase.includes?(user.email.split("@").first.downcase)
          errors << "Password cannot contain your username or email"
          strength = [strength - 20, 0].max
        end
      end

      # Bonus for extra length
      if password.size >= 16
        strength += 10
      end

      strength = [strength, 100].min

      if errors.empty?
        ValidationResult.success(strength)
      else
        ValidationResult.failure(errors, strength)
      end
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
      return true if user.password_changed_at.nil?

      expiry_date = user.password_changed_at.not_nil! + Security.password_expiry_days.days
      Time.utc > expiry_date
    end

    # Get days until password expiry
    def days_until_expiry(user : User) : Int32?
      return nil if Security.password_expiry_days <= 0
      return 0 if user.password_changed_at.nil?

      expiry_date = user.password_changed_at.not_nil! + Security.password_expiry_days.days
      remaining = (expiry_date - Time.utc).total_days.to_i
      [remaining, 0].max
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
      reqs << "At least one uppercase letter (A-Z)" if Security.password_require_uppercase
      reqs << "At least one lowercase letter (a-z)" if Security.password_require_lowercase
      reqs << "At least one number (0-9)" if Security.password_require_number
      reqs << "At least one special character (!@#$%^&*...)" if Security.password_require_special
      reqs << "Cannot be one of your last #{Security.password_history_count} passwords" if Security.password_history_count > 0
      reqs << "Cannot be a commonly used password"
      reqs
    end
  end
end
