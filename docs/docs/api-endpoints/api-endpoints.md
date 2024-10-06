# API Endpoints

This section documents all the available API endpoints in the Authority project. Each endpoint serves a specific purpose, such as managing OAuth clients, handling user sessions, or authorizing users.

### 1. Clients Endpoints

The `clients` endpoints manage OAuth clients that represent applications interacting with the Authority system.

*   `POST /clients`: Create a new OAuth client.

    Example Request:

    ```json
    {
      "name": "My App",
      "redirect_uri": "https://myapp.com/callback"
    }
    ```

    Example Response:

    ```json
    {
      "client_id": "abc123",
      "client_secret": "xyz789"
    }
    ```
*   `GET /clients`: Retrieve a list of registered OAuth clients.

    \
    Example Response:

    ```json
    [
      {
        "client_id": "abc123",
        "name": "My App",
        "redirect_uri": "https://myapp.com/callback"
      }
    ]
    ```

### 2. Owner Endpoints

The `owner` endpoints manage resource owners, allowing the Authority system to verify and manage access to resources owned by users.

*   `GET /owner`: Retrieve information about the authenticated resource owner.

    Example Response:

    ```json
    {
      "id": 1,
      "name": "John Doe",
      "email": "johndoe@example.com"
    }
    ```

### 3. Sessions Endpoints

The `sessions` endpoints manage user sessions, including login and logout functionality.

*   `POST /sessions/login`: Authenticate a user and create a session.

    Example Request:

    ```json
    {
      "email": "user@example.com",
      "password": "password123"
    }
    ```

    Example Response:

    ```json
    {
      "access_token": "token123"
    }
    ```
*   `POST /sessions/logout`: Log out the authenticated user and invalidate the session.

    Example Response:

    ```json
    {
      "message": "Logged out successfully"
    }
    ```

### 4. Authorize Endpoints

The `authorize` endpoints manage the OAuth authorization flow.

* `GET /authorize`: Redirect users to the OAuth provider for authorization.
  * Example Response: Redirects the user to the OAuth provider's login page.
*   `POST /authorize`: Handle the authorization code returned by the OAuth provider and exchange it for an access token.

    Example Request:

    ```json
    {
      "authorization_code": "code123"
    }
    ```

    Example Response:

    ```json
    {
      "access_token": "token123"
    }
    ```

### 5. Device Endpoints

The `device` endpoints manage device-specific interactions, such as registering or authenticating devices.

*   `POST /device/register`: Register a new device.

    Example Request:

    ```json
    {
      "device_id": "device123",
      "device_name": "John's Phone"
    }
    ```

    Example Response:

    ```json
    {
      "message": "Device registered successfully"
    }
    ```

### 6. Access Token Endpoints

The `access_token` endpoints handle the management of access tokens, including issuing, refreshing, and revoking tokens.

*   `POST /access_token`: Exchange an authorization code for an access token.

    Example Request:

    ```json
    {
      "authorization_code": "code123"
    }
    ```

    Example Response:

    ```json
    {
      "access_token": "token123",
      "expires_in": 3600
    }
    ```
*   `POST /access_token/revoke`: Revoke an access token.

    Example Request:

    ```json
    {
      "access_token": "token123"
    }
    ```

    Example Response:

    ```json
    {
      "message": "Access token revoked"
    }
    ```

### 7. Health Check

The `health_check.cr` endpoint is used to check the health of the Authority service.

*   `GET /health_check`: Returns the status of the service.

    Example Response:

    ```json
    {
      "status": "healthy"
    }
    ```
