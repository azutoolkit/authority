# Admin Users Revoke Session Request
module Authority::Dashboard::Users
  struct RevokeSessionRequest
    include Request

    getter id : String = ""           # User ID
    getter session_id : String = ""   # Session ID to revoke
  end
end
