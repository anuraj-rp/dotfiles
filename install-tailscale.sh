#!/bin/bash

set -e

# Clean mode: stop and disable tailscale service
if [ "$1" == "--clean" ]; then
    echo "Cleaning up tailscale service..."

    if command -v brew &> /dev/null; then
        # macOS cleanup
        if brew services list | grep -q "tailscale.*started"; then
            brew services stop tailscale
            echo "Stopped tailscale service"
        fi
    else
        # Ubuntu/Linux cleanup
        if systemctl is-active --quiet tailscaled; then
            sudo systemctl stop tailscaled
            echo "Stopped tailscaled service"
        fi

        if systemctl is-enabled --quiet tailscaled 2>/dev/null; then
            sudo systemctl disable tailscaled
            echo "Disabled tailscaled service"
        fi
    fi

    echo "Cleanup complete! (tailscale package still installed)"
    exit 0
fi

# Clean all mode: uninstall tailscale completely
if [ "$1" == "--clean-all" ]; then
    echo "Completely removing tailscale..."

    if command -v brew &> /dev/null; then
        # macOS uninstall
        if brew services list | grep -q "tailscale.*started"; then
            brew services stop tailscale
            echo "Stopped tailscale service"
        fi
        brew uninstall tailscale
        echo "Uninstalled tailscale"
    else
        # Ubuntu/Linux uninstall
        if systemctl is-active --quiet tailscaled; then
            sudo systemctl stop tailscaled
            echo "Stopped tailscaled service"
        fi

        if systemctl is-enabled --quiet tailscaled 2>/dev/null; then
            sudo systemctl disable tailscaled
            echo "Disabled tailscaled service"
        fi

        sudo apt remove -y tailscale
        sudo apt autoremove -y
        echo "Uninstalled tailscale"

        # Remove tailscale repository
        if [ -f /etc/apt/sources.list.d/tailscale.list ]; then
            sudo rm /etc/apt/sources.list.d/tailscale.list
            echo "Removed tailscale apt repository"
        fi

        if [ -f /usr/share/keyrings/tailscale-archive-keyring.gpg ]; then
            sudo rm /usr/share/keyrings/tailscale-archive-keyring.gpg
            echo "Removed tailscale GPG key"
        fi
    fi

    # Remove tailscale data directory (both platforms)
    if [ -d /var/lib/tailscale ]; then
        sudo rm -rf /var/lib/tailscale
        echo "Removed tailscale data directory"
    fi

    echo "Full uninstall complete!"
    exit 0
fi

echo "Installing tailscale..."

if command -v tailscale &> /dev/null; then
    echo "tailscale is already installed ($(tailscale version))"
else
    if command -v brew &> /dev/null; then
        # macOS installation
        brew install tailscale
        echo "tailscale installed successfully"
    elif command -v apt &> /dev/null; then
        # Ubuntu/Debian installation using official script
        curl -fsSL https://tailscale.com/install.sh | sh
        echo "tailscale installed successfully"
    else
        echo "Error: Unsupported platform. This script supports Ubuntu and macOS only."
        exit 1
    fi
fi

echo "Enabling and starting tailscale service..."
if command -v brew &> /dev/null; then
    # macOS service management
    if ! brew services list | grep -q "tailscale.*started"; then
        brew services start tailscale
        echo "tailscale service started"
    else
        echo "tailscale service is already running"
    fi
else
    # Ubuntu/Linux service management
    if ! systemctl is-active --quiet tailscaled 2>/dev/null; then
        sudo systemctl enable --now tailscaled
        echo "tailscaled service started"
    else
        echo "tailscaled service is already running"
    fi
fi

echo ""
echo "tailscale setup complete!"
echo ""
echo "To connect to tailscale:"
echo "  sudo tailscale up"
echo ""
echo "To check status:"
echo "  tailscale status"
echo ""
echo "To get your tailscale IP:"
echo "  tailscale ip"
echo ""
echo "To disconnect:"
echo "  sudo tailscale down"
echo ""
echo "To clean up:"
echo "  $0 --clean      # Stop and disable service only"
echo "  $0 --clean-all  # Completely uninstall tailscale"
