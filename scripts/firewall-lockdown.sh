#!/bin/bash
# Firewall Lockdown Script

read -p "Enter your SSH port (the one you configured earlier): " SSH_PORT

echo "[*] Applying firewall rules..."
ufw --force reset
ufw default deny incoming
ufw default allow outgoing
ufw allow $SSH_PORT/tcp
ufw --force enable
ufw reload

echo "[+] Firewall locked down. Only port $SSH_PORT is open for SSH."
