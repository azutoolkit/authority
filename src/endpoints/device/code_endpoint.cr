module Authority::Device
  class CodeEndpoint
    include Endpoint(CodeRequest, CodeResponse)
    post "/device/code"

    def call : CodeResponse
      status 201

      header "Content-Type", "application/json;charset=UTF-8"
      header "Cache-Control", "no-store"
      header "Pragma", "no-cache"

      CodeResponse.new device_code
    end

    def device_code
      DeviceCodeRepo.create!(client)
    end

    def client
      ClientRepo.find_by! code_request.client_id
    end
  end
end
