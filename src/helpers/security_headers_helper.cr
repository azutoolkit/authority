# Security Headers Helper
# Adds security-related HTTP headers to prevent common web vulnerabilities.
# Include this module in endpoints that return HTML content.
module Authority
  module SecurityHeadersHelper
    macro included
      # Sets security headers to protect against XSS, clickjacking, and other attacks.
      # Call this method in endpoints that return HTML content.
      def set_security_headers!
        # Prevent MIME type sniffing
        header "X-Content-Type-Options", "nosniff"

        # Prevent clickjacking by disallowing framing
        header "X-Frame-Options", "DENY"

        # Enable XSS filter in browsers (legacy, but still useful for older browsers)
        header "X-XSS-Protection", "1; mode=block"

        # Control information sent in Referer header
        header "Referrer-Policy", "strict-origin-when-cross-origin"

        # Content Security Policy - restrict resource loading
        header "Content-Security-Policy", csp_policy

        # HTTP Strict Transport Security - force HTTPS
        header "Strict-Transport-Security", "max-age=31536000; includeSubDomains"
      end

      private def csp_policy : String
        "default-src 'self'; " \
        "script-src 'self' 'unsafe-inline' https://cdn.tailwindcss.com https://cdn.jsdelivr.net https://unpkg.com; " \
        "style-src 'self' 'unsafe-inline' https://fonts.googleapis.com https://cdn.jsdelivr.net; " \
        "font-src 'self' https://fonts.gstatic.com; " \
        "img-src 'self' data: https:; " \
        "frame-ancestors 'none'; " \
        "form-action 'self'"
      end
    end
  end
end
