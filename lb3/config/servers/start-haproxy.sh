#!/bin/sh

set -eux
# Install haproxy if not already installed
apk add --no-cache haproxy

# assign an IP address to eth1 for internal network communication
ip addr add 10.10.10.100/24 dev eth1 || true
ip link set eth1 up

# Check if config exists
if [ ! -f /etc/haproxy/haproxy.cfg ]; then
  echo "ERROR: /etc/haproxy/haproxy.cfg not found!"
#   exit 1
fi

# Start haproxy in the foreground
haproxy -f /etc/haproxy/haproxy.cfg

# tail -f /dev/null

# sh -c "apk add haproxy && haproxy -f /etc/haproxy/haproxy.cfg"