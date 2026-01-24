module Authority::Landing
  struct PageResponse
    include Response
    include Templates::Renderable

    TEMPLATE = "auth/landing/page.html"

    def render
      view TEMPLATE, {
        signin_path:    "/signin",
        docs_path:      "/.well-known/openid-configuration",
        github_url:     "https://github.com/azutoolkit/authority",
        token_endpoint: "/token",
        auth_endpoint:  "/authorize",
      }
    end
  end
end
