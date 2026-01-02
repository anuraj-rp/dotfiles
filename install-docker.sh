#!/usr/bin/env bash
# install-docker.sh — Install Docker Engine on Ubuntu or macOS
# Safe to run multiple times.
# Based on Docker's official installation script: https://get.docker.com

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

        sudo apt-get remove -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-ce-rootless-extras
        sudo apt-get autoremove -y
        echo "Uninstalled docker packages"

        # Remove docker repository files
        if [ -f /etc/apt/sources.list.d/docker.sources ]; then
            sudo rm /etc/apt/sources.list.d/docker.sources
            echo "Removed docker apt repository (docker.sources)"
        fi

        if [ -f /etc/apt/sources.list.d/docker.list ]; then
            sudo rm /etc/apt/sources.list.d/docker.list
            echo "Removed docker apt repository (docker.list)"
        fi

        if [ -f /etc/apt/keyrings/docker.asc ]; then
            sudo rm /etc/apt/keyrings/docker.asc
            echo "Removed docker GPG key (docker.asc)"
        fi

        if [ -f /etc/apt/keyrings/docker.gpg ]; then
            sudo rm /etc/apt/keyrings/docker.gpg
            echo "Removed docker GPG key (docker.gpg)"
        fi

        # Remove docker data
        if [ -d /var/lib/docker ]; then
            sudo rm -rf /var/lib/docker
            echo "Removed docker data directory"
        fi

        if [ -d /var/lib/containerd ]; then
            sudo rm -rf /var/lib/containerd
            echo "Removed containerd data directory"
        fi
    fi

    echo "Full uninstall complete!"
    exit 0
fi

# Use official Docker script: use this for reliable cross-platform installation
if [ "$1" == "--official" ]; then
    echo "Using Docker's official installation script..."
    curl -fsSL https://get.docker.com -o /tmp/get-docker.sh
    sudo sh /tmp/get-docker.sh
    rm /tmp/get-docker.sh

    echo ""
    echo "docker installed successfully!"
    echo ""
    echo "To run docker without sudo:"
    echo "  sudo usermod -aG docker \$USER && newgrp docker"
    echo ""
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
    elif command -v apt-get &> /dev/null; then
        # Ubuntu/Debian installation (following official Docker documentation)
        # Reference: https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository
        echo "Installing prerequisites..."
        sudo apt-get update
        sudo apt-get install -y ca-certificates curl

        echo "Setting up docker repository..."
        sudo install -m 0755 -d /etc/apt/keyrings

        # Download Docker's official GPG key
        if [ ! -f /etc/apt/keyrings/docker.asc ]; then
            sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
            sudo chmod a+r /etc/apt/keyrings/docker.asc
            echo "Downloaded Docker GPG key"
        fi

        # Get system codename (prefer UBUNTU_CODENAME if available)
        CODENAME=$(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")

        # Add the repository using DEB822 format (.sources file)
        sudo tee /etc/apt/sources.list.d/docker.sources > /dev/null <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: ${CODENAME}
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF

        echo "Installing docker packages..."
        sudo apt-get update

        # Install with retry logic for package availability
        # If default installation fails, try specific containerd.io versions
        if ! sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin; then
            echo ""
            echo "Installation failed. Trying with specific containerd.io version..."

            # Try version 2.2.0-2 (known stable version)
            if sudo apt-get install -y containerd.io=2.2.0-2~ubuntu.24.04~noble docker-ce docker-ce-cli docker-buildx-plugin docker-compose-plugin; then
                echo "Successfully installed Docker with containerd.io 2.2.0-2"
            # Fallback to version 1.7.29-1 if 2.2.0-2 fails
            elif sudo apt-get install -y containerd.io=1.7.29-1~ubuntu.24.04~noble docker-ce docker-ce-cli docker-buildx-plugin docker-compose-plugin; then
                echo "Successfully installed Docker with containerd.io 1.7.29-1"
            else
                echo "Error: Failed to install Docker. Please check package availability."
                exit 1
            fi
        fi

        # Enable and start docker service
        if command -v systemctl &> /dev/null; then
            sudo systemctl enable docker
            sudo systemctl start docker
            echo "Docker service enabled and started"
        fi

        # Add current user to docker group to run docker without sudo
        if [ -n "$SUDO_USER" ]; then
            # Script was run with sudo, add the actual user
            sudo usermod -aG docker "$SUDO_USER"
            echo "Added $SUDO_USER to docker group"
        elif [ "$USER" != "root" ]; then
            # Script run without sudo by non-root user
            sudo usermod -aG docker "$USER"
            echo "Added $USER to docker group"
        fi

        echo "docker installed successfully"
    else
        echo "Error: Unsupported platform. This script supports Ubuntu and macOS only."
        exit 1
    fi
fi

echo ""
echo "docker setup complete!"
echo ""
echo "IMPORTANT: Log out and log back in for docker group changes to take effect."
echo "Or run: newgrp docker (to apply in current session)"
echo ""
echo "To verify installation:"
echo "  docker --version"
echo "  docker run hello-world"
echo ""
echo "To clean up:"
echo "  $0 --clean      # Stop and disable service only"
echo "  $0 --clean-all  # Completely uninstall docker"
echo "  $0 --official   # Use Docker's official installation script"
