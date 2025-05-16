#!/bin/sh
set -eux
# Not used
# Set hostname
vtysh -c "configure terminal" \
      -c "hostname router" \
      -c "log stdout" \
      -c "interface eth1" \
      -c "ip address 10.10.10.1/24" \
      -c "exit" \
      -c "ip route 10.10.10.0/24 eth1" \
      -c "line vty" \
      -c "end" \
      -c "write memory"

# apk update
# ip link add name br0 type bridge

# ip link set dev eth1 master br0

# ip addr add 192.168.1.1/24 dev br0

# ip link set dev br0 up
# ip link set dev eth1 up

# echo "setup complete"