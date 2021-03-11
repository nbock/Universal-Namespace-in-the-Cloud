
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

# Later setcap depends on libcap2-bin library
RUN apt-get update
RUN apt-get install -y libcap2-bin

# Add user named upspin
RUN useradd -m upspin

# Work directory will be in format /home/{$USER}
WORKDIR /home/upspin

# Copy the upspinserver binary from previous build to current image
COPY --from=build --chown=upspin:upspin /go/src/upspin/upspin/upspinserver .

# Let upspinserver binary listen on ports 80 and 443 without running it as root
RUN setcap cap_net_bind_service=+ep ./upspinserver

# This directiory is needed for HTTPS connections
RUN mkdir -p upspin/letsencrypt

EXPOSE 443 80

# Run upspinserver as user upspin we just created
USER upspin:upspin

# Start the server with some additional flags indicating it to
# run in HTTP with localhost as server address (This needs to be 
# further changes)
CMD ./upspinserver