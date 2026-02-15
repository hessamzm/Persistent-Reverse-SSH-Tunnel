# Persistent-Reverse-SSH-Tunnel
Highly stable reverse SSH tunnel architecture designed for unreliable networks.
#  Persistent Reverse SSH Tunnel (Central ↔ Edge Servers)

Highly stable reverse SSH tunnel architecture designed for unreliable / filtered networks.

This project provides simple installation scripts for building a **persistent reverse SSH tunnel** between:

(in country) Central Server (Central)  
 Edge Servers (Germany / UK / USA / etc)

Designed for real-world unstable connectivity scenarios.

---

## Features

 Reverse SSH Architecture (Edge → Central)  
 Real disconnect detection (autossh monitoring)  
 Persistent systemd service  
 Stable under packet loss / interference  
 Key-based authentication  
 Compatible with Xray / VLESS / Shadowsocks setups  

---

##  Architecture Overview

Edge Servers initiate outbound SSH connections to Central server.

Why?

Outbound connections are significantly more reliable than inbound ones in restricted networks.


Edge Servers (Outside) ───▶ Central Server (Central)


---

#  Central Server Setup (Central)

Run on your **Central server**:

```bash
wget https://raw.githubusercontent.com/hessamzm/Persistent-Reverse-SSH-Tunnel/main/central-setup.sh
bash central-setup.sh
 What Central Script Does

 System update
 Installs required packages
 Generates SSH tunnel key
 Applies SSH stability settings
 Displays public key for edges

 Public Key Output

After installation:

===== COPY THIS KEY TO EDGE SERVERS =====
ssh-rsa AAAA....

Save this key.

You will paste it on each edge server.

 Edge Server Setup (Outside Central)

Run on every edge server:

wget https://raw.githubusercontent.com/hessamzm/Persistent-Reverse-SSH-Tunnel/main/edge-setup.sh
bash edge-setup.sh
 Edge Script Inputs

The script will ask for:

Central Server IP

Central SSH Port

Central Public Key (paste)

Paste the key generated on Central server.

 Tunnel Stability Mechanism

This setup uses:

autossh monitoring port

Real keepalive detection

systemd auto-restart

Behavior

 No response for 120 seconds → connection considered dead
 systemd waits 60 seconds → restart
 autossh rebuilds tunnel

Fully persistent.

 Recommended Port Design

Typical deployment:

Service	Port
VLESS / TLS	443
HTTP / Panel	8080
Shadowsocks	8000

Routing should be handled by Xray / panel layer.

 Service Management

Check tunnel status:

systemctl status reverse-tunnel

Logs:

journalctl -u reverse-tunnel -n 50 --no-pager

Restart:

systemctl restart reverse-tunnel
 Troubleshooting
 Tunnel not coming up

Verify SSH reachability:

telnet Central_IP 22

Check firewall:

iptables -L -n
ufw status

Check SSH daemon:

systemctl status ssh
 Security Notes

 Uses key-based authentication
 Password login optional but discouraged
 Consider fail2ban for SSH hardening
 Changing SSH port recommended

 Optional: Installing Xray Panel (3X-UI / Sanaei)

This tunnel works perfectly with Xray panels.

Example with 3X-UI (Sanaei Panel):

 Install Panel

On Central server:

bash <(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh)
 Access Panel

Default:

http://SERVER_IP:2053

(Port may vary depending on installer version)

 Important First Steps

After login:

 Change username & password
 Enable TLS if exposing publicly
 Configure inbound ports

Typical Inbounds

Recommended:

VLESS + TCP + TLS → Port 443

Shadowsocks → Port 8000

Panel HTTP → Port 8080

Multi-Edge Usage

You can connect multiple edge servers:

Germany
UK
USA
Any region

All pointing to the same Central server.

Panel can distribute subscriptions (sub links) containing all nodes.

 License

MIT License
