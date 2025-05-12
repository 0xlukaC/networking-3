#!/bin/sh

echo "Hello switch1!"

# Exit on errors, print commands, fail on pipeline errors
set -euxo pipefail

# Redirect output to container logs
exec > >(tee /proc/1/fd/1) 2>&1

# Ensure correct environment variables
export PATH="/usr/lib/frr:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
export LD_LIBRARY_PATH="/usr/lib/frr:${LD_LIBRARY_PATH:-}"

# Enable IP forwarding
sysctl -w net.ipv4.ip_forward=1
sysctl -w net.ipv6.conf.all.forwarding=1

# Start FRR daemons
echo "Starting FRR daemons..."
# /usr/lib/frr/zebra -d
# /usr/lib/frr/ospfd -d
# /usr/lib/frr/bgpd -d

# Confirm zebra started
if ! pgrep zebra > /dev/null; then
    echo "FRR daemons failed to start" >&2
    exit 1
fi

# Wait for interfaces to come up
echo "Waiting for interfaces to become ready..."
for iface in $(ip -br link | awk '$1 !~ /@/ && $2 == "UP" {print $1}'); do
    while ! ip link show "$iface" > /dev/null 2>&1; do
        echo "Waiting for $iface to exist..."
        sleep 1
    done

    while ! ip -br link show "$iface" | grep -q "UP"; do
        echo "Waiting for $iface to be fully up..."
        sleep 1
    done

    echo "$iface is up"
done

# Set up Linux bridge
echo "Creating Linux bridge br0"
ip link add name br0 type bridge

# Add interfaces to bridge, skip eth0
for iface in $(ip -br link | awk '$2 == "UP" {print $1}' | cut -d'@' -f1); do
    [ "$iface" = "eth0" ] && continue
    echo "Adding $iface to bridge br0"
    ip link set "$iface" up
    ip link set "$iface" master br0
done

# Bring bridge up
ip link set dev br0 up

echo "Bridge setup complete!"
ip -br link

# Replace shell with daemon monitor to keep container alive
# exec /usr/lib/frr/watchfrr -d
