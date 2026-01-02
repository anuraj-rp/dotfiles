#!/usr/bin/env bash
# install-docker.sh — Install Docker Engine on Ubuntu using keyring/signed-by (Ubuntu 24.04+)
# Steps included: 1–8 from guidance (no hello-world run, no apt-key del)
# Safe to run multiple times.
set -euo pipefail

# 1) Prereqs
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg

# 2) Create keyring dir (if not present)
sudo install -m 0755 -d /etc/apt/keyrings

# 3) Fetch and install Docker’s GPG key (dearmored) to the keyring
if [ ! -f /etc/apt/keyrings/docker.gpg ]; then
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
fi

# 4) Ensure world-readable (required by apt)
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# 5) Write the Docker apt source with signed-by and the correct codename
CODENAME=$(. /etc/os-release && echo "$VERSION_CODENAME")
ARCH=$(dpkg --print-architecture)
REPO_LINE="deb [arch=${ARCH} signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu ${CODENAME} stable"

# Create/replace docker.list only if content differs
LIST_FILE=/etc/apt/sources.list.d/docker.list
if [ -f "$LIST_FILE" ]; then
  CURRENT=$(sudo cat "$LIST_FILE" || true)
else
  CURRENT=""
fi
if [ "$CURRENT" != "$REPO_LINE" ]; then
  echo "$REPO_LINE" | sudo tee "$LIST_FILE" > /dev/null
fi

# Remove any old .save file that could confuse apt (optional)
sudo rm -f /etc/apt/sources.list.d/docker.list.save

# 6) Update apt
sudo apt-get update

# 7) Install Docker packages
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# 8) Optionally add current user to docker group (commented out)
# sudo usermod -aG docker "$USER"
# newgrp docker

# Completion message
echo "Docker installation completed. If you want to run docker without sudo, add your user to the 'docker' group and re-login:"
echo "  sudo usermod -aG docker $USER && newgrp docker"
