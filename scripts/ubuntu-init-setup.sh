#!/bin/bash
# VPS Initial Setup Script for Ubuntu

# --- Check for root privileges ---
if [ "$EUID" -ne 0 ]; then
    echo "[!] This script must be run as root (try: sudo bash $0)"
    exit 1
fi

# --- Ask for user input ---
read -p "Enter new username: " NEW_USER
read -p "Enter new SSH port (default 2222): " SSH_PORT
SSH_PORT=${SSH_PORT:-2222}

read -p "Enter your SSH public key: " PUB_KEY

echo "[*] Updating system packages..."
apt update && apt upgrade -y
apt autoremove -y

echo "[*] Creating new user '$NEW_USER' (no password)..."
# Create user without password
adduser --gecos "" "$NEW_USER" --disabled-password
usermod -aG sudo "$NEW_USER"

echo "[*] Installing SSH key for the new user..."
mkdir -p "/home/$NEW_USER/.ssh"
printf "%s\n" "$PUB_KEY" > "/home/$NEW_USER/.ssh/authorized_keys"
chmod 700 "/home/$NEW_USER/.ssh"
chmod 600 "/home/$NEW_USER/.ssh/authorized_keys"
chown -R "$NEW_USER:$NEW_USER" "/home/$NEW_USER/.ssh"

# --- Function to update or add sshd_config entries ---
set_config() {
    local KEY=$1
    local VALUE=$2
    if grep -q "^[[:space:]]*$KEY" /etc/ssh/sshd_config; then
        # Update existing active (non-comment) line
        sed -i "s|^[[:space:]]*$KEY.*|$KEY $VALUE|" /etc/ssh/sshd_config
    else
        # Append new line if not present
        echo "$KEY $VALUE" >> /etc/ssh/sshd_config
    fi
}

echo "[*] Securing SSH configuration..."
set_config "PermitRootLogin" "no"
set_config "PasswordAuthentication" "no"
set_config "ChallengeResponseAuthentication" "no"
set_config "KbdInteractiveAuthentication" "no"
set_config "PubkeyAuthentication" "yes"
set_config "Port" "$SSH_PORT"

echo "[*] Testing SSH configuration syntax..."
if sshd -t; then
    echo "[+] SSH configuration is valid. Reloading sshd..."
    systemctl reload ssh
else
    echo "[!] SSH configuration has errors. Please check /etc/ssh/sshd_config"
    exit 1
fi

echo "[*] Installing and configuring UFW (firewall)..."
apt install ufw -y
ufw allow "$SSH_PORT"/tcp
ufw --force enable

echo "[*] Enabling automatic security updates..."
apt install unattended-upgrades -y
dpkg-reconfigure --priority=low unattended-upgrades

echo "[*] Enabling time synchronization and setting timezone..."
timedatectl set-timezone Asia/Tehran
timedatectl set-ntp on

echo "[+] Setup completed."
echo "--------------------------------"
echo " SSH test command (use your SSH key):"
echo "   ssh -p $SSH_PORT $NEW_USER@your_server_ip"
echo "--------------------------------"
echo "[!] IMPORTANT: This account has NO password. You must use the SSH key you provided."
echo "[!] After you confirm SSH key login on port $SSH_PORT, run 'firewall-lockdown.sh' to close other ports."
