# Admin Clients Bulk Operation Request
module Authority::Dashboard::Clients
  struct BulkRequest
    include Request

    getter action : String = ""      # "delete", "export"
    getter ids : Array(String) = [] of String
  end
end
