FROM docker.io/crystallang/crystal:latest-alpine
WORKDIR /opt/app
COPY . /opt/app
RUN crystal build --static ./src/authority.cr -o ./server
CMD ["crystal", "spec"]

FROM alpine:latest  
RUN apk --no-cache add ca-certificates
WORKDIR /root/
COPY --from=0 /opt/app/server .
COPY --from=0 /opt/app/public ./public/
CMD ["./server"]