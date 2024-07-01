# Use the official Golang image as the base image
FROM golang:1.17

# Install necessary tools, libraries and dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libgmp3-dev \
    jq \
    libusb-1.0-0 \
    libusb-1.0-0-dev

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
