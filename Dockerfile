
FROM crystallang/crystal:latest-alpine as source
WORKDIR /opt/app
COPY . /opt/app
RUN shards install
RUN crystal build --static ./src/authority.cr -o ./authority
CMD ["crystal", "spec"]

FROM alpine:latest  
RUN apk --no-cache add ca-certificates
WORKDIR /root/
COPY --from=source /opt/app/authority .
COPY --from=source /opt/app/public ./public
CMD ["./authority"]

