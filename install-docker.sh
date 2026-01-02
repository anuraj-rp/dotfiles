#!/usr/bin/env bash
# install-docker.sh — Install Docker Engine on Ubuntu or macOS
# Safe to run multiple times.

set -e

# Clean mode: stop docker service
if [ "$1" == "--clean" ]; then
    echo "Cleaning up docker service..."

    if command -v brew &> /dev/null; then
        # macOS cleanup
        if brew services list | grep -q "docker.*started"; then
            brew services stop docker
            echo "Stopped docker service"
        fi
    else
        # Ubuntu cleanup
        if systemctl is-active --quiet docker; then
            sudo systemctl stop docker
            echo "Stopped docker service"
        fi

        if systemctl is-enabled --quiet docker 2>/dev/null; then
            sudo systemctl disable docker
            echo "Disabled docker service"
        fi
    fi

    echo "Cleanup complete! (docker still installed)"
    exit 0
fi

# Clean all mode: uninstall docker completely
if [ "$1" == "--clean-all" ]; then
    echo "Completely removing docker..."

    if command -v brew &> /dev/null; then
        # macOS uninstall
        if brew services list | grep -q "docker.*started"; then
            brew services stop docker
            echo "Stopped docker service"
        fi
        brew uninstall --cask docker
        echo "Uninstalled docker"
    else
        # Ubuntu uninstall
        if systemctl is-active --quiet docker; then
            sudo systemctl stop docker
            echo "Stopped docker service"
        fi

        if systemctl is-enabled --quiet docker 2>/dev/null; then
            sudo systemctl disable docker
            echo "Disabled docker service"
        fi

        sudo apt remove -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
        sudo apt autoremove -y
        echo "Uninstalled docker packages"

        # Remove docker repository
        if [ -f /etc/apt/sources.list.d/docker.list ]; then
            sudo rm /etc/apt/sources.list.d/docker.list
            echo "Removed docker apt repository"
        fi

        if [ -f /etc/apt/keyrings/docker.gpg ]; then
            sudo rm /etc/apt/keyrings/docker.gpg
            echo "Removed docker GPG key"
        fi

        # Remove docker data
        if [ -d /var/lib/docker ]; then
            sudo rm -rf /var/lib/docker
            echo "Removed docker data directory"
        fi
    fi

    echo "Full uninstall complete!"
    exit 0
fi

echo "Installing docker..."

if command -v docker &> /dev/null; then
    echo "docker is already installed ($(docker --version))"
else
    if command -v brew &> /dev/null; then
        # macOS installation
        brew install --cask docker
        echo "docker installed successfully"
        echo "Note: You may need to start Docker Desktop manually from Applications"
    elif command -v apt &> /dev/null; then
        # Ubuntu installation
        echo "Installing prerequisites..."
        sudo apt update
        sudo apt install -y ca-certificates curl gnupg

        echo "Setting up docker repository..."
        sudo install -m 0755 -d /etc/apt/keyrings

        if [ ! -f /etc/apt/keyrings/docker.gpg ]; then
            curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
            | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
        fi

        sudo chmod a+r /etc/apt/keyrings/docker.gpg

        CODENAME=$(. /etc/os-release && echo "$VERSION_CODENAME")
        ARCH=$(dpkg --print-architecture)
        REPO_LINE="deb [arch=${ARCH} signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu ${CODENAME} stable"

        LIST_FILE=/etc/apt/sources.list.d/docker.list
        if [ -f "$LIST_FILE" ]; then
            CURRENT=$(sudo cat "$LIST_FILE" || true)
        else
            CURRENT=""
        fi
        if [ "$CURRENT" != "$REPO_LINE" ]; then
            echo "$REPO_LINE" | sudo tee "$LIST_FILE" > /dev/null
        fi

        sudo rm -f /etc/apt/sources.list.d/docker.list.save

        echo "Installing docker packages..."
        sudo apt update
        sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
        echo "docker installed successfully"
    else
        echo "Error: Unsupported platform. This script supports Ubuntu and macOS only."
        exit 1
    fi
fi

echo ""
echo "docker setup complete!"
echo ""
echo "To run docker without sudo (Ubuntu only):"
echo "  sudo usermod -aG docker \$USER && newgrp docker"
echo ""
echo "To verify installation:"
echo "  docker --version"
echo ""
echo "To clean up:"
echo "  $0 --clean      # Stop and disable service only"
echo "  $0 --clean-all  # Completely uninstall docker"
