# Admin Audit Logs Index Request
module Authority::Dashboard::AuditLogs
  struct IndexRequest
    include Request

    getter page : Int32 = 1
    getter actor_id : String?
    getter action : String?
    getter resource_type : String?
    getter start_date : String?
    getter end_date : String?
  end
end
