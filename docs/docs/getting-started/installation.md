# Installation

### Prerequisites

* Crystal language installed. Follow the official [Crystal installation guide](https://crystal-lang.org/install/).
* PostgreSQL or another supported database.
* Docker (if using Docker setup).

### Steps

1.  Clone the repository:

    <pre class="language-bash"><code class="lang-bash"><strong>git clone &#x3C;repository-url>
    </strong>cd authority
    </code></pre>
2.  Install dependencies:

    ```bash
    shards install
    ```
3.  Set up the database:

    ```bash
    createdb authority_db
    ```
4.  Configure environment variables in `.env.local`:

    ```bash
    cp .env.example .env.local
    ```
5.  Run the application:

    ```bash
    crystal run src/app.cr
    ```

Or using Docker:

```bash
docker-compose up --build
```
