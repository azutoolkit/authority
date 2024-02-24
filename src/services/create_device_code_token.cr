module Authority
  class DeviceCodeToken
    private getter device_code : DeviceCode
    private getter client_id : String

    def self.activate!(activate_request : Device::ActivateRequest)
      DeviceCodeRepo.activate!(activate_request.user_code, activate_request.verification)
    end

    def self.token(device_code_request : Device::TokenRequest)
      new(device_code_request).token
    end

    def initialize(req : Device::TokenRequest)
      @client_id = req.client_id
      @device_code = DeviceCodeRepo.find_by!(req.code, req.client_id)
    end

    def token
      raise device_code.errors.map(&.reason).join(", ") unless device_code.valid?
      Authly::AccessToken.new client_id, scope: "", id_token: nil
    end
  end
end
