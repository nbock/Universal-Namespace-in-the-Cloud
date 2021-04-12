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

# Just an example for how to install other packages in the docker file, could be deleted if not needed
RUN apt-get update
RUN apt-get install -y gettext libnss-wrapper

# Add user named upspin
RUN useradd -m upspin

# Create the /upspin directory in Dockerfile manually for now
# RUN mkdir -p /upspin
# RUN chgrp -R 0 /upspin && chmod -R g+rwX /upspin


# Work directory will be in format /home/{$USER}
WORKDIR /home/upspin

# Set the vaule of environment variable HOME as /home/upspin in this container
ENV HOME=/home/upspin


# Copy the upspinserver binary from previous build to current image
COPY --from=build /go/src/upspin/upspin/upspinserver .

# This directiory is needed for HTTPS connections
RUN mkdir -p upspin/letsencrypt
RUN mkdir -p upspin/server
RUN mkdir -p upspin/server/storage

# Refer to Support Arbitrary User IDs section in 
# https://docs.openshift.com/container-platform/3.11/creating_images/guidelines.html#openshift-specific-guidelines
# RUN chgrp -R 0 upspin/letsencrypt && chmod -R g+rwX upspin/letsencrypt

# Set the ownership of upspin directory as root group, and add r,w,x permission to the root group
RUN chgrp -R 0 upspin && chmod -R g+rwX upspin

# Add the local file into Docker image
ADD passwd.template .
ADD start.sh .
RUN chmod +x ./start.sh

EXPOSE 6443 8080

# Run upspinserver as user upspin we just created
USER upspin

# Mount
VOLUME "/home/upspin/upspin/"


# Currently the pod could not handle the external https request correctly. See the details in the log of pod.
# CMD ./upspinserver -https=:6443 -http=:8080

# The pod could handle the external http request correctly with the insecure flag though
# CMD ./upspinserver -insecure=true -https=:6443 -http=:8080


CMD ./start.sh
