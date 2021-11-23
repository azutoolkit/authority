module Authority
  module DeviceCodeRepo
    def self.find_by!(device_code_id, client_id)
      DeviceCodeEntity.query.find!({
        id:        device_code_id,
        client_id: client_id,
      })
    end

    def self.activate!(code : String, verification : String)
      DeviceCodeEntity.query
        .where { user_code == code }.to_update
        .set(verification: verification).execute
    end

    def self.create!(client : ClientEntity)
      user_code = "#{Random.new.hex(3)}".upcase
      DeviceCodeEntity.new({
        id:               UUID.random,
        client_id:        client.client_id,
        client_name:      client.name,
        user_code:        user_code,
        verification:     Verification::Pending,
        verification_uri: Authority::ACTIVATE_URL,
        expires_at:       DEVICE_CODE_TTL.seconds.from_now,
        created_at:       Time.utc,
      }).save!
    end
  end
end
