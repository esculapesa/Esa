# Use the official Golang image as the base image
FROM golang:1.21-alpine as builder

# Install necessary tools, libraries, and dependencies
RUN apk add --no-cache gcc musl-dev linux-headers git build-base libgmp-dev jq libusb-dev

# Support setting various labels on the final image
ARG COMMIT=""
ARG VERSION=""
ARG BUILDNUM=""

# Clone the Core Geth repository and build it
RUN git clone https://github.com/esculapesa/Esa.git /root/Esa && \
    cd /root/Esa && \
    git checkout Esa && \
    make geth

# Copy the entrypoint script into the container
COPY entrypoint.sh /root/Esa/entrypoint.sh
RUN chmod +x /root/Esa/entrypoint.sh

# Set the working directory
WORKDIR /root/Esa

# Expose necessary ports
EXPOSE 8545 8546 30303 30303/udp

# Use entrypoint.sh as the entrypoint
ENTRYPOINT ["/root/Esa/entrypoint.sh"]

# Add some metadata labels to help programmatic image consumption
LABEL commit="$COMMIT" version="$VERSION" buildnum="$BUILDNUM"
