# Endpoint Docs https://azutopia.gitbook.io/azu/endpoints
module Authority::Authorize
  class NewEndpoint
    include Endpoint(NewRequest, EmptyResponse | FormResponse)

    get "/authorize"

    def call : EmptyResponse | FormResponse
      return signin unless user_logged_in?
      FormResponse.new(new_request, "/authorize")
    end

    def signin
      redirect to: "/signin?forward_url=#{forward_url}", status: 302
      EmptyResponse.new
    end

    def forward_url
      Base64.urlsafe_encode(context.request.path + "?" + context.request.query.not_nil!)
    end

    def user_logged_in?
      Session.id(cookies)
    end
  end
end
