module Authority
  class CreateDeviceCode
    def self.create(client_id : String)
      new(client_id).create_device_code
    end

    def initialize(@client_id : String)
    end

    def create_device_code
      DeviceCodeRepo.create!(client)
    end

    def client
      Authority.client_repo.find_by! @client_id
    end
  end
end
