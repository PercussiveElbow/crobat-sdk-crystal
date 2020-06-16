FROM crystallang/crystal:latest-alpine AS builder
RUN apk --no-cache add ca-certificates
RUN apk update && apk upgrade
WORKDIR /app
COPY . /app
RUN crystal build --static --release /app/src/crobat_client.cr 
FROM busybox:latest
WORKDIR /app
COPY --from=builder  /app/crobat_client /app/crobat_client
COPY --from=builder /etc/ssl/certs /etc/ssl/certs
ENTRYPOINT ["/app/crobat_client"]
