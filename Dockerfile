# Use the official Golang image as the base image
FROM golang:1.21-alpine

# Install necessary tools, libraries, and dependencies
RUN apk add --no-cache gcc musl-dev linux-headers git build-base gmp-dev jq libusb-dev

# Support setting various labels on the final image
ARG COMMIT=""
ARG VERSION=""
ARG BUILDNUM=""

# Clone the Core Geth repository and build it
RUN git clone https://github.com/esculapesa/Esa.git /root/Esa && \
    cd /root/Esa && \
    git checkout EsaLatest && \
    make geth

# Debugging step to list contents of the root directory
RUN echo "Listing contents of /root before copying entrypoint.sh:" && ls -la /root


# Copy the entrypoint script into the container
COPY entrypoint.sh /root/Esa/entrypoint.sh

# Debugging step to list contents of the /root/Esa directory
RUN echo "Listing contents of /root/Esa after copying entrypoint.sh:" && ls -la /root/Esa

RUN chmod +x /root/Esa/entrypoint.sh

# Set the working directory
WORKDIR /root/Esa

# Expose necessary ports
EXPOSE 8545 8546 30303 30303/udp

# Use entrypoint.sh as the entrypoint
ENTRYPOINT ["/root/Esa/entrypoint.sh"]

# Add some metadata labels to help programmatic image consumption
LABEL commit="$COMMIT" version="$VERSION" buildnum="$BUILDNUM"
