# Build image to compile the app
FROM crystallang/crystal:latest-alpine AS builder
RUN apk update && apk upgrade && apk --no-cache add ca-certificates
WORKDIR /app
RUN adduser -S lowpriv
COPY ./src /app/src/
RUN crystal build --static --release /app/src/crobat_client.cr 

# Build the lightweight busybox based image
FROM scratch
COPY --from=builder /etc/passwd /etc/passwd
COPY --from=builder  /app/crobat_client /app/crobat_client
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/cert.pem
USER lowpriv
ENTRYPOINT ["/app/crobat_client"]
