#!/bin/sh

# Install haproxy if not already installed
apk add --no-cache haproxy

# Check if config exists
if [ ! -f /etc/haproxy/haproxy.cfg ]; then
  echo "ERROR: /etc/haproxy/haproxy.cfg not found!"
#   exit 1
fi

# Start haproxy in the foreground
haproxy -f /etc/haproxy/haproxy.cfg

tail -f /dev/null

# sh -c "apk add haproxy && haproxy -f /etc/haproxy/haproxy.cfg"