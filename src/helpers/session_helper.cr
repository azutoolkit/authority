module Authority
  module SessionHelper
    macro included
      # Define a method to check if the user is authenticated if not redirect to signin
      # page with the current path as the forward_url
      # If the user is authenticated return the current session
      #
      # @return [Session] the current session
      # @return [Nil] if the user is not authenticated
      # @example
      def authenticated?
        current_session.authenticated?
      end

      def redirect_to_signin(redirect_url = forward_url)
        redirect to: "/signin?forward_url=#{redirect_url}", status: 302
      end

      def forward_url
        Base64.urlsafe_encode(context.request.path + "?" + context.request.query.not_nil!)
      end

      def current_session
        Authority.current_session
      end
    end
  end
end
