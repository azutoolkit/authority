module Authority
  class ConfirmPasswordValidator < Schema::Validator
    getter :record, :field, :message

    def initialize(@record : Owner::NewRequest | Account::PasswordResetConfirmRequest)
      @field = :password
      @message = "Password did not match with confirm password."
    end

    def valid? : Array(Schema::Error)
      if @record.password != @record.confirm_password
        [Schema::Error.new @field, @message]
      else
        [] of Schema::Error
      end
    end
  end
end
