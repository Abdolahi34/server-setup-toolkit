#!/bin/bash
# -----------------------------
# SSH Login Telegram Notifier
# -----------------------------

read -p "🔑 Enter the Server Name: " SERVER_NAME
read -p "🔑 Enter the Telegram bot token: " BOT_TOKEN
read -p "💬 Enter Telegram chat_id: " CHAT_ID

# Install curl if needed
echo "📦 Install curl if needed..."
sudo apt update -y
sudo apt install -y curl

# Creating a notification sending script
echo "📝 Create a notification script..."
cat <<EOF | sudo tee /usr/local/bin/ssh_notify.sh >/dev/null
#!/bin/bash
if [ "$PAM_TYPE" != "open_session" ]; then
    exit 0
fi

BOT_TOKEN="$BOT_TOKEN"
CHAT_ID="$CHAT_ID"
SERVER_NAME="$SERVER_NAME"
IP=\$(echo \$SSH_CONNECTION | awk '{print \$1}')
USER=\$(whoami)
DATE=\$(date '+%Y-%m-%d %H:%M:%S')

TEXT="🚨 لاگین جدید SSH 🚨
💻 سرور: \$SERVER_NAME
👤 کاربر: \$USER
🌍 آی‌پی: \$IP
📅 زمان: \$DATE"

curl -s -X POST https://api.telegram.org/bot\$BOT_TOKEN/sendMessage \\
    -d chat_id=\$CHAT_ID \\
    -d text="\$TEXT" >/dev/null
EOF

# Execute access to the script
sudo chmod +x /usr/local/bin/ssh_notify.sh

# Add to PAM
echo "⚙️ PAM configuration..."
if ! grep -q "ssh_notify.sh" /etc/pam.d/sshd; then
    echo "session optional pam_exec.so seteuid /usr/local/bin/ssh_notify.sh" | sudo tee -a /etc/pam.d/sshd
fi

echo "✅ Settings done."
echo "Every time an SSH login is performed, a message is sent to Telegram 🚀"
