#!/bin/bash
# 🛡️ Hardening Script for RustDesk & Zero-Trust Access
set -e

echo "[*] Configuring UFW Default Policies..."
sudo ufw default deny incoming
sudo ufw default allow outgoing

echo "[*] Restricting Management Interfaces to Tailscale Overlay Network..."
sudo ufw allow in on tailscale0 to any port 22 proto tcp comment 'SSH over Tailscale'
sudo ufw allow in on tailscale0 to any port 80 proto tcp comment 'CasaOS Web UI over Tailscale'

echo "[*] Opening RustDesk Signaling and Relay Ports..."
sudo ufw allow 21115:21119/tcp comment 'RustDesk TCP Ports'
sudo ufw allow 21116/udp comment 'RustDesk UDP Signaling'

echo "[*] Enabling Firewall..."
echo "y" | sudo ufw enable

echo "[✔] Firewall Rules Applied Successfully!"
sudo ufw status verbose
