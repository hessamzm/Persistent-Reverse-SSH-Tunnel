#!/bin/bash

echo "======================================="
echo "        EDGE SERVER INSTALLER"
echo "======================================="
echo ""

read -p "Enter IRAN SERVER IP: " IRAN_IP
read -p "Enter IRAN SSH PORT: " IRAN_PORT

echo ""
echo "Paste IRAN PUBLIC KEY (tunnel_key.pub)"
echo "Finish with ENTER then CTRL+D"
echo ""

PUB_KEY=$(cat)

if [ -z "$IRAN_IP" ] || [ -z "$IRAN_PORT" ] || [ -z "$PUB_KEY" ]; then
    echo ""
    echo "❌ Missing required values"
    exit 1
fi

echo ""
echo "Updating system..."
apt update -y && apt upgrade -y

echo "Installing required packages..."
apt install -y autossh openssh-client

echo "Configuring SSH access..."

mkdir -p /root/.ssh
chmod 700 /root/.ssh

echo "$PUB_KEY" >> /root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys

echo "Creating persistent reverse tunnel service..."

cat <<EOF > /etc/systemd/system/reverse-tunnel.service
[Unit]
Description=Reverse SSH Tunnel to Iran
After=network.target

[Service]
ExecStart=/usr/bin/autossh -M 20000 -N -R 2222:localhost:22 root@${IRAN_IP} -p ${IRAN_PORT} \\
  -o ServerAliveInterval=40 \\
  -o ServerAliveCountMax=3 \\
  -o TCPKeepAlive=yes \\
  -o ExitOnForwardFailure=yes \\
  -o StrictHostKeyChecking=no

Restart=always
RestartSec=60

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable reverse-tunnel
systemctl restart reverse-tunnel

echo ""
echo "✅ EDGE SERVER READY"
echo ""
echo "Tunnel Behavior:"
echo "• Real disconnect detection → 120 seconds"
echo "• Restart delay → 60 seconds"
echo ""
