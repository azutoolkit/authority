module Authority
  module SessionHelper
    macro included
      def signin(redirect_url = forward_url)
        redirect to: "/signin?forward_url=#{redirect_url}", status: 302
        EmptyResponse.new
      end

      def forward_url
        Base64.urlsafe_encode(context.request.path + "?" + context.request.query.not_nil!)
      end

      def current_session
        Authority.session.current_session
      end
    end
  end
end
