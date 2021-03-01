#This is a multistage docker file where build process is
#seperated from the deployment

# Base image of golang to build binaries of upspinserver
FROM golang:latest as build

WORKDIR /go/src

# Clone the git repo of upspin
RUN git clone https://github.com/upspin/upspin.git
WORKDIR /go/src/upspin/upspin

# Build the binaries
RUN GOOS=linux GOARCH=amd64 go build upspin.io/cmd/upspinserver

# Start a new image base of ubuntu
FROM ubuntu:latest

# Add user named upspin
RUN useradd -m upspin

# Change the current user to upspin
USER upspin:upspin

# Work directory will be in format /home/{$USER}
WORKDIR /home/upspin

# Copy the upspinserver binary from previous build to current image
COPY --from=build --chown=upspin:upspin /go/src/upspin/upspin/upspinserver .

# This directiory is needed for HTTPS connections
RUN mkdir -p upspin/letsencrypt

# Currently running the server on HTTP with port 2000
EXPOSE 2000

# Start the server with some additional flags indicating it to
# run in HTTP with localhost as server address (This needs to be 
# further changes)
CMD ./upspinserver  -insecure=true -http=localhost:2000




