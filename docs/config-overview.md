
# Configuration Overview

The Authority project includes several important configuration files located in the `src/config` directory. These files define settings for key components of the application, including sessions, authentication, and the overall system behavior.

## Available Configuration Files

### 1. session.cr

The `session.cr` file handles session management for the application. Sessions are crucial for maintaining user state between requests, especially in authentication systems.

Key settings:
- Session duration: Define how long a session should remain active before expiring.
- Storage options: Configure where session data is stored (e.g., in-memory or database-backed).

You can adjust session behavior based on your requirements by modifying this file.

### 2. authly.cr

The `authly.cr` file is responsible for authentication-related settings. This includes OAuth configuration and other authentication logic.

Key settings:
- OAuth client configuration: Define client IDs, secrets, and other OAuth-specific settings.
- Authentication flows: Customize how the system handles different types of authentication (e.g., token-based or session-based).

### 3. clear.cr

The `clear.cr` file likely manages caching and clearing of session data or other temporary data. This file ensures that outdated session data or cache entries are purged efficiently.

Key settings:
- Cache expiration: Define when cached data should be invalidated.
- Manual clearing options: Set up specific points where data is cleared to optimize performance.

### 4. authority.cr

The `authority.cr` file contains the main configurations for the Authority authentication system. This file ties together various authentication and authorization components.

Key settings:
- General system settings: Configure global behavior for the Authority system.
- Custom provider options: Define how different authentication providers are integrated with the system.

## Customizing Configuration

To customize any of these settings, simply open the corresponding configuration file in the `src/config` directory and adjust the necessary parameters. Be sure to restart the application after making changes to ensure that the new configurations are applied.
