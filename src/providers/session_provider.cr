module Authority
  module SessionProvider
    macro included
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
end
