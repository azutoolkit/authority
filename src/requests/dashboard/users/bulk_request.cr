# Admin Users Bulk Operation Request
module Authority::Dashboard::Users
  struct BulkRequest
    include Request

    getter action : String = "" # "lock", "unlock", "delete", "export"
    getter ids : Array(String) = [] of String
    getter reason : String = "" # For lock action
  end
end
