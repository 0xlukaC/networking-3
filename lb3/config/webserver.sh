#!/bin/bash

set -eu

script_path="$0"
port=8080
script_name=$(basename "$script_path")

while ! ip link show eth1 2>/dev/null; do
    sleep 0.1
done

if echo "$script_path" | grep -q "1"; then
    port=80
    ip addr add 10.10.10.11/24 dev eth1
    ip link set eth1 up
elif echo "$script_path" | grep -q "2"; then
    port=80
    ip addr add 10.10.10.12/24 dev eth1
    ip link set eth1 up
fi



apk add --no-cache gcc musl-dev file
chmod +w /config

gcc /config/web.c -o /config/exec.exe -pthread
chmod +x /config/exec.exe

# file /config/exec.exe

echo "$port"
/config/exec.exe "$port" # execute the compiled C program
tail -f /dev/null
