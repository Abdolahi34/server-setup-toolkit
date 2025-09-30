#!/bin/bash
# SSH Key Generator Script
# This script creates a new SSH key pair with a custom name and comment.

# --- Default settings ---
SSH_DIR="$HOME/.ssh"         # Path where keys will be stored
KEY_TYPE="ed25519"           # Key algorithm (ed25519 is modern and secure)
KDF_ROUNDS=100                 # Extra rounds of KDF (for better protection)
DEFAULT_NAME="id_${KEY_TYPE}" # Default base name for the key

# --- Ask for user input ---
read -p "Enter a name for the server/project (e.g., server1): " SERVER_NAME

# If no input provided, use defaults
SERVER_NAME=${SERVER_NAME:-default}

# Final key file path
KEY_FILE="$SSH_DIR/${DEFAULT_NAME}_${SERVER_NAME}"

# --- Create .ssh directory if not exists ---
if [ ! -d "$SSH_DIR" ]; then
    echo "[*] Creating $SSH_DIR directory..."
    mkdir -p "$SSH_DIR"
    chmod 700 "$SSH_DIR"
fi

# --- Check if the key already exists ---
if [ -f "$KEY_FILE" ]; then
    echo "[!] Key already exists: $KEY_FILE"
    echo "    Please choose a different name or backup/remove the old key."
    exit 1
fi

# --- Generate SSH key pair ---
echo "[*] Generating new SSH key..."
ssh-keygen -t "$KEY_TYPE" -a "$KDF_ROUNDS" -f "$KEY_FILE" -C "${SERVER_NAME}_key"
chmod 600 "$KEY_FILE"

# --- Output results ---
echo "[+] SSH key created successfully!"
echo "    Private key: $KEY_FILE"
echo "    Public key : ${KEY_FILE}.pub"
echo
echo "[!] IMPORTANT: Keep your private key secure. Share only the public key."
