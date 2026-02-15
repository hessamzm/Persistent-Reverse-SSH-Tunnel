#!/bin/bash

echo "=== IRAN CENTRAL SERVER SETUP ==="

echo "Updating system..."
apt update -y && apt upgrade -y

echo "Installing required packages..."
apt install -y openssh-server autossh curl

echo "Ensuring SSH is enabled..."
systemctl enable ssh
systemctl restart ssh

echo "Generating tunnel key..."
mkdir -p /root/.ssh
chmod 700 /root/.ssh

if [ ! -f /root/.ssh/tunnel_key ]; then
    ssh-keygen -t ed25519 -f /root/.ssh/tunnel_key -N ""
fi

chmod 600 /root/.ssh/tunnel_key

echo "Applying SSH stability settings..."

SSHD_CONFIG="/etc/ssh/sshd_config"

sed -i 's/^#\?ClientAliveInterval.*/ClientAliveInterval 60/' $SSHD_CONFIG
sed -i 's/^#\?ClientAliveCountMax.*/ClientAliveCountMax 999/' $SSHD_CONFIG
sed -i 's/^#\?TCPKeepAlive.*/TCPKeepAlive yes/' $SSHD_CONFIG

grep -q "^ClientAliveInterval" $SSHD_CONFIG || echo "ClientAliveInterval 60" >> $SSHD_CONFIG
grep -q "^ClientAliveCountMax" $SSHD_CONFIG || echo "ClientAliveCountMax 999" >> $SSHD_CONFIG
grep -q "^TCPKeepAlive" $SSHD_CONFIG || echo "TCPKeepAlive yes" >> $SSHD_CONFIG
grep -q "^GatewayPorts" $SSHD_CONFIG || echo "GatewayPorts yes" >> $SSHD_CONFIG

systemctl restart ssh || systemctl restart sshd

echo ""
echo "✅ CENTRAL SERVER READY"
echo ""
echo "===== COPY THIS PUBLIC KEY TO EDGE SERVERS ====="
cat /root/.ssh/tunnel_key.pub
echo "==============================================="
