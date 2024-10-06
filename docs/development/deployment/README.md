# Deployment

This tutorial walks you through a quick setup of **Authority**, a **PostgreSQL** instance, and a simple User Login & Consent App based on Docker Compose. You need to have the latest [Docker](https://www.docker.com) and [Docker Compose](https://docs.docker.com/compose) version installed.

### Dockerfile

Authority project contains a simple Dockerfile that compiles and builds a simple docker image with little to no dependencies.

```docker
FROM crystallang/crystal:latest-alpine as source
WORKDIR /opt/app
COPY . /opt/app
RUN shards install
RUN crystal build --release --static ./src/server.cr -o ./server
CMD ["crystal", "spec"]

FROM alpine:latest  
RUN apk --no-cache add ca-certificates
WORKDIR /root/
COPY --from=source /opt/app/server .
COPY --from=source /opt/app/public ./public
CMD ["./server"]
```

### Docker-Compose

To start using Authority run the following command

```
docker-compose up server
```

{% hint style="info" %}
To change the Authority server configuration change the **local.env** file
{% endhint %}

```yaml
version: "3.7"
services:
  db:
    image: postgres
    restart: always
    environment:
      POSTGRES_DB: authority_db
      POSTGRES_USER: auth_user
      POSTGRES_PASSWORD: auth_pass
    ports:
      - 5432:5432

  server:
    build:
      context: .
      dockerfile: Dockerfile
    command: ./server
    container_name: authority-server
    working_dir: /root/
    env_file:
      - local.env
    ports:
      - "4000:4000"
    depends_on:
      - db
```

