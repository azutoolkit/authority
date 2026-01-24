
# API Documentation

Authority exposes several API endpoints for authentication. Below are some key endpoints:

- `POST /auth/login`: Authenticate a user and obtain a token.
- `GET /auth/user`: Retrieve authenticated user details.
- `POST /auth/logout`: Log out a user.

Each endpoint accepts and returns JSON data. Ensure that you include the correct OAuth token in the Authorization header for protected routes.
