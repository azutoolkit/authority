module Authority::Device
  struct CodeResponse
    include Response
    getter device_code : DeviceCodeEntity

    def initialize(@device_code : DeviceCodeEntity)
    end

    def render
      {
        device_code:       device_code.id.to_s,
        user_code:         device_code.user_code,
        verification_uri:  device_code.verification_uri,
        verification_full: "#{device_code.verification_uri}?#{verification_path}",
        audience:          device_code.client_name,
        expires_in:        300,
        interval:          5,
      }.to_json
    end

    def verification_path
      "audience=#{device_code.client_name}&user_code=#{device_code.user_code}"
    end
  end
end
