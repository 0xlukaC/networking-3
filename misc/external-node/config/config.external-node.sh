#!/bin/sh

set -eu

IP_ADDR="$1"
CIDR_MASK="$2"

apk update && apk add openssh sudo iproute2 bash

if ! id -u testuser >/dev/null 2>&1; then
  adduser -D testuser
  echo "testuser:testpass" | chpasswd
  addgroup testuser wheel
fi

sed -i 's/^#PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
sed -i 's/^PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config

ssh-keygen -A

ip addr add "${IP_ADDR}/${CIDR_MASK}" dev eth1
ip link set eth0 up

mkdir -p /var/run/sshd
exec /usr/sbin/sshd -D

