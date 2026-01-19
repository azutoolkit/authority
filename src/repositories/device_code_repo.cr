module Authority
  module DeviceCodeRepo
    def self.find_by!(device_code_id : String, client_id : String) : DeviceCode
      DeviceCode.where(id: device_code_id, client_id: client_id).first!
    end

    def self.activate!(code : String, verification : String)
      device_code = DeviceCode.find_by!(user_code: code)
      device_code.verification = verification
      device_code.save!
    end

    def self.create!(client : Client, user_code = Random.new.hex(3).upcase) : DeviceCode
      device_code = DeviceCode.new
      device_code.client_id = client.client_id
      device_code.client_name = client.name
      device_code.user_code = user_code
      device_code.verification = "pending"
      device_code.verification_uri = Authority::ACTIVATE_URL
      device_code.expires_at = DEVICE_CODE_TTL.seconds.from_now
      device_code.save!
      device_code
    end
  end
end
