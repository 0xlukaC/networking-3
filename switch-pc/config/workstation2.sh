#!/bin/sh

MY_USERNAME=georgekun
MY_IP=10.0.0.101
MY_SUBNET=24
MY_ETHERNET=eth1

echo "configure $MY_USERNAME"
adduser -D -H "$MY_USERNAME"
echo "$MY_USERNAME:$MY_USERNAME" | chpasswd

mkdir /home/$MY_USERNAME
chown root:$MY_USERNAME /home/$MY_USERNAME

chmod u+rwx,g+rw /home/$MY_USERNAME