# Stage 1: Build the Go application
FROM golang:1.26-alpine AS builder

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN CGO_ENABLED=0 GOOS=linux go build -trimpath -ldflags="-s -w" -o skillpulse .

# Stage 2: Run the application
FROM gcr.io/distroless/static-debian12:nonroot

WORKDIR /app

COPY --from=builder /app/skillpulse /app/skillpulse

EXPOSE 8080

ENTRYPOINT ["/app/skillpulse"]
