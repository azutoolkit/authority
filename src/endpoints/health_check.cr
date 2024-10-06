module Authority
  struct HealthCheckResponse
    include Response

    def render
      {status: "ok"}.to_json
    end
  end

  struct HealthCheck
    include Endpoint(Request, HealthCheckResponse)

    get "/health_check"

    def call : Response
      HealthCheckResponse.new
    end
  end
end
