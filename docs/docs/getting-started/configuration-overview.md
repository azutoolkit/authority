# Configuration Overview

The Authority project includes several important configuration files located in the `src/config` directory. These files define settings for key components of the application, including sessions, authentication, and the overall system behavior.

### Available Configuration Files

#### 1. session.cr

The `session.cr` file handles session management for the application. Sessions are crucial for maintaining user state between requests, especially in authentication systems.

Key settings:

* Session duration: Define how long a session should remain active before expiring.
* Storage options: Configure where session data is stored (e.g., in-memory or database-backed).

You can adjust session behavior based on your requirements by modifying this file.

```crystal
require "session"

Session.configure do |c|
  c.timeout = 1.hour
  c.session_key = ENV.fetch "SESSION_KEY", "authority.sess"
  c.secret = ENV.fetch "SESSION_SECRET", "K,n:aT5CY4Trkg2JjS\e/?F[?e(Pj/n"
  c.on_started = ->(sid : String, data : Session::Databag) { Authority.log.info { "Session started - SessionID: #{sid} - Databag: #{data}" } }
  c.on_deleted = ->(sid : String, data : Session::Databag) { Authority.log.info { "Session Revoke - SessionID: #{sid} - Databag: #{data}" } }
  c.on_loaded = ->(sid : String, data : Session::Databag) { Authority.log.info { "Session Loaded - SessionID: #{sid} - Databag: #{data}" } }
  c.on_client = ->(sid : String, data : Session::Databag) { Authority.log.info { "Session Client - SessionID: #{sid} - Databag: #{data}" } }
end
```

#### 2. authly.cr

The `authly.cr` file is responsible for authentication-related settings. This includes OAuth configuration and other authentication logic.

Key settings:

* OAuth client configuration: Define client IDs, secrets, and other OAuth-specific settings.
* Authentication flows: Customize how the system handles different types of authentication (e.g., token-based or session-based).

```crystal
require "authly"

# Configure
Authly.configure do |c|
  c.secret_key = ENV.fetch "SECRET_KEY"
  c.refresh_ttl = ENV.fetch("REFRESH_TTL").try &.to_i.minutes
  c.code_ttl = ENV.fetch("CODE_TTL").try &.to_i.minutes
  c.access_ttl = ENV.fetch("ACCESS_TOKEN_TTL").try &.to_i.minutes
  c.owners = Authority::OwnerProvider.new
  c.clients = Authority::ClientProvider.new
end
```

#### 3. clear.cr

The `clear.cr` file likely manages caching and clearing of session data or other temporary data. This file ensures that outdated session data or cache entries are purged efficiently.

Key settings:

* Cache expiration: Define when cached data should be invalidated.
* Manual clearing options: Set up specific points where data is cleared to optimize performance.

```crystal
require "clear"

# Clear Orm Docs
# https://clear.gitbook.io/project/introduction/installation
Clear::SQL.init(ENV["DATABASE_URL"])
```

#### 4. authority.cr

The `authority.cr` file contains the main configurations for the Authority authentication system. This file ties together various authentication and authorization components.

Key settings:

* General system settings: Configure global behavior for the Authority system.
* Custom provider options: Define how different authentication providers are integrated with the system.

```crystal
require "azu"
Log.setup_from_env

module Authority
  include Azu

  SESSION_KEY     = ENV.fetch "SESSION_KEY", "session_id"
  BASE_URL        = ENV.fetch "BASE_URL", "http://localhost:4000"
  ACTIVATE_URL    = "#{BASE_URL}/activate"
  DEVICE_CODE_TTL = ENV.fetch("DEVICE_CODE_TTL", "300").to_i
  SESSION         = Session::CookieStore(UserSession).provider

  HANDLERS = [
    Azu::Handler::Rescuer.new,
    Azu::Handler::RequestID.new,
    Azu::Handler::Logger.new,
    Session::SessionHandler.new(Authority.session),
  ]

  def self.session
    SESSION
  end

  def self.current_session
    SESSION.current_session
  end

  configure do |c|
    c.templates.path = ENV["TEMPLATE_PATH"]
    c.router.get "/*", Handler::Static.new
  end
end

```

### Customizing Configuration

To customize any of these settings, simply open the corresponding configuration file in the `src/config` directory and adjust the necessary parameters. Be sure to restart the application after making changes to ensure that the new configurations are applied.
