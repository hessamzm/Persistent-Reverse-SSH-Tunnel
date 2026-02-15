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

# ذخیره امن نام کاربری و رمز عبور
echo "Storing credentials securely..."
echo "IRAN_USER=\"$IRAN_USER\"" > /root/.tunnel_auth
echo "IRAN_PASS=\"$IRAN_PASS\"" >> /root/.tunnel_auth
chmod 600 /root/.tunnel_auth

echo "Creating persistent reverse tunnel service..."

cat <<'EOF' > /etc/systemd/system/reverse-tunnel.service
[Unit]
Description=Reverse SSH Tunnel to Iran (via password auth)
After=network.target

[Service]
Type=simple
EnvironmentFile=/root/.tunnel_auth
ExecStart=/usr/bin/sshpass -p "${IRAN_PASS}" /usr/bin/autossh -M 20000 -N -R ${REVERSE_PORT}:localhost:22 ${IRAN_USER}@${IRAN_IP} -p ${IRAN_PORT} \
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

# جایگزینی متغیرها در سرویس
sed -i "s/REVERSE_PORT/${REVERSE_PORT}/g" /etc/systemd/system/reverse-tunnel.service
sed -i "s/IRAN_IP/${IRAN_IP}/g" /etc/systemd/system/reverse-tunnel.service
sed -i "s/IRAN_PORT/${IRAN_PORT}/g" /etc/systemd/system/reverse-tunnel.service

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
echo "Reverse tunnel active on port: ${REVERSE_PORT}"
echo ""

