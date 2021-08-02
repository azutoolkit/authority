module Authority
  module EndpointHelpers
    BASIC = "Basic"
    AUTH  = "Authorization"

    def credentials
      value = header[AUTH]
      client_id, client_secret = Base64.decode_string(value[BASIC.size + 1..-1]).split(":")
      {client_id, client_secret}
    end
  end
end
