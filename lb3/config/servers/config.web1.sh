#!/bin/sh
set -eux
sleep 1 # due to race condition

# Wait for eth1 to appear
#while ! ip link show eth1 2>/dev/null; do
#  echo "Waiting for eth1 to be available..."
#  sleep 1
#done

ip addr add 10.10.10.11/24 dev eth1
ip link set eth1 up
apk add --no-cache nginx
rm -f /etc/nginx/conf.d/default.conf
nginx -g "daemon off;"


# set -eux
# # rm /etc/nginx/conf.d/default.conf
# ip addr add 10.10.10.11/24 dev eth1
# ip link set eth1 up
# nginx -g "daemon off;"
# # tail -f /dev/null