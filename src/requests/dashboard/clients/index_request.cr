# Admin Clients Index Request
# Used for listing OAuth clients with pagination and filtering
module Authority::Dashboard::Clients
  struct IndexRequest
    include Request

    getter page : Int32 = 1
    getter search : String = ""
    getter confidentiality : String = ""  # "confidential", "public", or "" for all
    getter scope : String = ""            # Filter by specific scope
    getter sort_by : String = "created_at"
    getter sort_dir : String = "DESC"
  end
end
