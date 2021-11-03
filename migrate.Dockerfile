
FROM crystallang/crystal:latest-alpine
WORKDIR /opt/app
COPY . /opt/app
RUN shards install
RUN crystal build --release --static ./taskfile.cr -o ./azu
CMD ["./azu", "db", "migrate"]