# Admin Settings Index Request
module Authority::Dashboard::Settings
  struct IndexRequest
    include Request

    getter tab : String = "security"
  end
end
