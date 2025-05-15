#!/bin/bash

echo "Hello switch1!"

# Enable immediate flushing of output
set -euxo pipefail
exec > >(tee /proc/1/fd/1) 2>&1

# Ensure correct environment variables are set
export PATH=/usr/lib/frr:$PATH
# export LD_LIBRARY_PATH=/usr/lib/frr:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH="/usr/lib/frr:${LD_LIBRARY_PATH:-}"


# Enable IP forwarding
sysctl -w net.ipv4.ip_forward=1
sysctl -w net.ipv6.conf.all.forwarding=1

# Check if zebra is already running to avoid starting it twice
if ! pgrep zebra > /dev/null; then
    echo "Starting up FRR daemons"
    /usr/lib/frr/zebra -d
    /usr/lib/frr/ospfd -d
    /usr/lib/frr/bgpd -d
else
    echo "FRR daemons are already running"
fi

# Check if FRR daemons are running
if ! pgrep zebra > /dev/null; then
    echo "FRR failed to start" >&2
    exit 1
fi

# Wait for the interfaces to be up
echo "Waiting for interfaces to load up"

# Loop over the interfaces and check for their status
for iface in $(ip -br link | awk '$1 !~ /@/ && $2 == "UP" {print $1}'); do
    while ! ip link show $iface > /dev/null 2>&1; do
        echo "Waiting for $iface to exist..."
        sleep 1
    done

    while ! ip -br link show $iface | grep -q "UP"; do
        echo "Waiting for $iface to be fully up..."
        sleep 1
    done

    echo "$iface is up"
done

echo "All interfaces are up!"

echo "Setting up Linux bridge"

# Create a Linux bridge instead of using FRR
# brctl addbr br0

ip link add name br0 type bridge
ip link set br0 up



# Add all UP interfaces to the bridge, ignoring the '@' part
# for iface in $(ip -br link | awk '$2 == "UP" {print $1}' | cut -d'@' -f1); do
#     echo "Adding $iface to bridge br0"
#     brctl addif br0 $iface
# done

for iface in $(ip -br link | awk '$2 == "UP" {print $1}' | cut -d'@' -f1); do
  [ "$iface" = "eth0" ] && continue  # skip Docker's interface
  echo "Adding $iface to bridge br0"
  ip link set "$iface" up
  brctl addif br0 "$iface"
done


# Bring the bridge up
ip link set dev br0 up

echo "Bridge setup complete!"

ip -br link

# sleep infinity
tail -f /dev/null