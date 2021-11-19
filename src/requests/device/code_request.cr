module Authority::Device
  struct CodeRequest
    include Request
    getter client_id : String

    validate client_id, message: "Param client_id must be present.", presence: true

    def valid_client?
      ClientRepo.find_by! client_id
    end
  end
end
