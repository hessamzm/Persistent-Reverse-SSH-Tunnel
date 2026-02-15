#!/bin/bash

echo "======================================="
echo "        EDGE SERVER INSTALLER"
echo "======================================="
echo ""

read -p "Enter IRAN SERVER IP: " IRAN_IP
read -p "Enter IRAN SSH PORT: " IRAN_PORT
read -p "Enter IRAN SERVER USERNAME: " IRAN_USER
read -s -p "Enter IRAN SERVER PASSWORD: " IRAN_PASS
echo ""
read -p "Enter REVERSE TUNNEL PORT (remote bind port): " REVERSE_PORT

if [ -z "$IRAN_IP" ] || [ -z "$IRAN_PORT" ] || [ -z "$IRAN_USER" ] || [ -z "$IRAN_PASS" ] || [ -z "$REVERSE_PORT" ]; then
    echo ""
    echo "❌ Missing required values"
    exit 1
fi

echo ""
echo "Updating system..."
apt update -y && apt upgrade -y

echo "Installing required packages..."
apt install -y autossh openssh-client sshpass

echo "Storing credentials securely..."
cat <<EOF > /root/.tunnel_auth
IRAN_USER="$IRAN_USER"
IRAN_PASS="$IRAN_PASS"
IRAN_IP="$IRAN_IP"
IRAN_PORT="$IRAN_PORT"
REVERSE_PORT="$REVERSE_PORT"
EOF

chmod 600 /root/.tunnel_auth

echo "Creating persistent reverse tunnel service..."

cat <<'EOF' > /etc/systemd/system/reverse-tunnel.service
[Unit]
Description=Reverse SSH Tunnel to Iran (via password auth)
After=network.target

[Service]
Type=simple
EnvironmentFile=/root/.tunnel_auth

ExecStart=/usr/bin/sshpass -p "$IRAN_PASS" \
  /usr/bin/autossh -M 20000 -N \
  -R $REVERSE_PORT:localhost:22 $IRAN_USER@$IRAN_IP -p $IRAN_PORT \
  -o ServerAliveInterval=40 \
  -o ServerAliveCountMax=3 \
  -o TCPKeepAlive=yes \
  -o ExitOnForwardFailure=yes \
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
echo "Reverse tunnel active on port: ${REVERSE_PORT}"
echo ""
