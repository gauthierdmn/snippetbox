ARG MAINTAINER="astro.gauthier@loftorbital.com"

# First stage: Build the Go application
FROM golang:1.21 AS dev

# Create the directory and set it as the working directory
WORKDIR /app

# Copy the entire project into the working directory
COPY . .

FROM dev AS build

# Change the working directory to where the main.go file is located
WORKDIR /app/cmd/web

# Build the Go application
# -o specifies the output binary name and location
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o /app/main .

# Second stage: Setup the runtime environment using the alpine base image
FROM alpine:latest AS prod

# Add CA certificates for HTTPS connections
RUN apk --no-cache add ca-certificates

# Create a non-root user for security purposes
RUN adduser -D nonroot

# Set the user and working directory for the non-root user
USER nonroot
WORKDIR /home/nonroot

# Copy the built binary and UI static files from the first stage to the non-root user's home directory
COPY --chown=nonroot:nonroot --from=build /app/main /home/nonroot/
COPY --chown=nonroot:nonroot --from=build /app/ui /home/nonroot/ui

# The application listens on port 8000 by default, expose it
EXPOSE 8000

# Command to run the application
CMD ["./main", "-addr=:8000"]
