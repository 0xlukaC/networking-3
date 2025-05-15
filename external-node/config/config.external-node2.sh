#!/bin/sh

# creates a log file
LOGFILE="/var/log/external-node-init.log"
mkdir -p "$(dirname "$LOGFILE")"
exec > >(tee -a "$LOGFILE") 2>&1 # redirects stdout/err to file
set -eux

IP_ADDR="$1" # IP address to assign to the container
CIDR_MASK="$2" # mask to assign to the container

apk update && apk add openssh sudo iproute2 bash iptables


# multiple users
USERS="testuser,luka,goge"
for user in $(echo $USERS | tr ',' ' '); do
  if ! id -u "$user" >/dev/null 2>&1; then
    adduser -D "$user"
    echo "$user:$user" | chpasswd # password is the same as user
    addgroup "$user" wheel # sudo group 
  fi
done

# SSH key injection from ENV for testuser
# no docker secrets
# if SSH_PUBKEY environment variable is set, inject it as an authorized key for testuser
if [ -n "${SSH_PUBKEY:-}" ]; then
  mkdir -p /home/testuser/.ssh
  echo "$SSH_PUBKEY" > /home/testuser/.ssh/authorized_keys
  chown -R testuser:testuser /home/testuser/.ssh
  chmod 700 /home/testuser/.ssh
  chmod 600 /home/testuser/.ssh/authorized_keys
fi


sed -i 's/^#PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
sed -i 's/^PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config

# custom login banner
# changed from "hi"
echo "       _,    _   _    ,_ 
  .o888P     Y8o8Y     Y888o.
 d88888      88888      88888b
d888888b_  _d88888b_  _d888888b
8888888888888888888888888888888
8888888888888888888888888888888
YJGS8P"Y888P"Y888P"Y888P"Y8888P
 Y888   '8'   Y8P   '8'   888Y
  '8o          V          o8'
    `                     `" > /etc/motd # message of the day
echo "authorised people only" > /etc/issue.net # 
grep -q '^Banner /etc/issue.net' /etc/ssh/sshd_config || echo "Banner /etc/issue.net" >> /etc/ssh/sshd_config # makes ssh use the banner, checks if it exists if not, adds it

ssh-keygen -A # generate host keys

# Dynamic network interface detection (use first ethX > 0)
# Find the first network interface named ethX (where x > 0) and assign the provided IP/CIDR to it as container may not have eth0
# NET_IFACE=$(ip -o link show | awk -F': ' '/eth[1-9]/{print $2; exit}')
# ip addr add "${IP_ADDR}/${CIDR_MASK}" dev "$NET_IFACE"
# ip link set eth0 up

for i in $(seq 1 10); do
  NET_IFACE=$(ip -o link show | awk -F': ' '/eth[1-9]/{print $2; exit}')
  if [ -n "$NET_IFACE" ]; then
    break
  fi
  echo "waiting for ethX interface to appear"
  sleep 1
done

# fallback to eth0 if no eth1+
if [ -z "$NET_IFACE" ]; then
  NET_IFACE="eth0"
  echo "No eth1+ interface found, falling back to $NET_IFACE"
fi

ip addr add "${IP_ADDR}/${CIDR_MASK}" dev "$NET_IFACE"
ip link set "$NET_IFACE" up

# Ip tables Allows up to 3 new SSH connections per minute from the same IP.
# Drops further attempts for 60 seconds. This is kinda useless if the container restarts.
iptables -A INPUT -p tcp --dport 22 -m state --state NEW -m recent --set
iptables -A INPUT -p tcp --dport 22 -m state --state NEW -m recent --update --seconds 60 --hitcount 4 -j DROP

# creates a file healthcheck to make sure sshd is running
cat <<EOF > /usr/local/bin/healthcheck.sh
#!/bin/sh
pgrep sshd && echo "sshd running" || exit 1 
EOF
chmod +x /usr/local/bin/healthcheck.sh

mkdir -p /var/run/sshd
exec /usr/sbin/sshd -D