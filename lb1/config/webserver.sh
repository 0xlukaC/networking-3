#!/bin/bash

set -eu

script_path="$0"
port=8080
script_name=$(basename "$script_path")

if echo "$script_path" | grep -q "1"; then
    port=80
elif echo "$script_path" | grep -q "2"; then
    port=80
fi




apk add --no-cache gcc musl-dev file
chmod +w /config

gcc /config/web.c -o /config/exec.exe -pthread
chmod +x /config/exec.exe

# file /config/exec.exe

echo "$port"
/config/exec.exe "$port" # execute the compiled C program
tail -f /dev/null
