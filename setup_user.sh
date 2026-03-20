#!/bin/bash

set -euo pipefail

# Setup User Script
# Creates a new user with SSH key authentication

if [ "$EUID" -ne 0 ]; then
    echo "Error: Please run as root (use sudo ./setup_user.sh)"
    exit 1
fi

# Prompt for username
read -rp "Enter username to create: " username

if [ -z "$username" ]; then
    echo "Error: Username cannot be empty."
    exit 1
fi

if id "$username" &> /dev/null; then
    echo "Error: User '$username' already exists."
    exit 1
fi

# Ask where to get authorized_keys from
echo ""
echo "Where should SSH authorized_keys come from?"
echo "  1) Copy from an existing user"
echo "  2) Paste a public key manually"
read -rp "Choose [1/2]: " key_source

case "$key_source" in
    1)
        read -rp "Copy keys from which user (default: root): " source_user
        source_user="${source_user:-root}"
        if [ "$source_user" = "root" ]; then
            source_keys="/root/.ssh/authorized_keys"
        else
            source_keys="/home/$source_user/.ssh/authorized_keys"
        fi
        if [ ! -f "$source_keys" ]; then
            echo "Error: $source_keys not found."
            exit 1
        fi
        ;;
    2)
        echo "Paste the public key (e.g. ssh-ed25519 AAAA... user@host), then press Enter:"
        read -rp "> " pubkey
        if [ -z "$pubkey" ]; then
            echo "Error: Public key cannot be empty."
            exit 1
        fi
        ;;
    *)
        echo "Error: Invalid choice."
        exit 1
        ;;
esac

# Create user
echo "Creating user '$username'..."
adduser --gecos "" "$username"

# Add to sudo group
echo "Adding '$username' to sudo group..."
usermod -aG sudo "$username"

# Set up SSH directory and install authorized_keys
echo "Setting up SSH keys..."
mkdir -p "/home/$username/.ssh"
if [ "$key_source" = "1" ]; then
    cp "$source_keys" "/home/$username/.ssh/authorized_keys"
else
    echo "$pubkey" > "/home/$username/.ssh/authorized_keys"
fi
chown -R "$username:$username" "/home/$username/.ssh"
chmod 700 "/home/$username/.ssh"
chmod 600 "/home/$username/.ssh/authorized_keys"

# Harden sshd_config
echo "Configuring sshd..."
sshd_config="/etc/ssh/sshd_config"

sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication no/' "$sshd_config"
sed -i 's/^#\?PubkeyAuthentication.*/PubkeyAuthentication yes/' "$sshd_config"

# Verify the settings are present (add if not found by sed)
grep -q "^PasswordAuthentication" "$sshd_config" || echo "PasswordAuthentication no" >> "$sshd_config"
grep -q "^PubkeyAuthentication" "$sshd_config" || echo "PubkeyAuthentication yes" >> "$sshd_config"

# Restart SSH service
echo "Restarting SSH service..."
systemctl restart ssh 2>/dev/null || systemctl restart sshd 2>/dev/null

echo ""
echo "Done! User '$username' has been set up:"
echo "  - sudo access granted"
echo "  - SSH keys installed"
echo "  - Password authentication disabled"
echo "  - Public key authentication enabled"
