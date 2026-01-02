#!/bin/bash

# Development Tools Installation Script
# Installs essential development tools (Ubuntu and macOS)

set -e

# Clean mode: not applicable for system packages
if [ "$1" == "--clean" ] || [ "$1" == "--clean-all" ]; then
    echo "Error: Cleanup not supported for system development tools."
    echo "To remove these packages, use your package manager directly:"
    if command -v brew &> /dev/null; then
        echo "  brew uninstall <package>"
    else
        echo "  sudo apt remove <package>"
    fi
    exit 1
fi

echo "========================================"
echo "Development Tools Installer"
echo "========================================"
echo ""

if command -v brew &> /dev/null; then
    # macOS installation
    echo "Platform: macOS"
    echo ""
    echo "Installing development tools via Homebrew..."

    # build-essential equivalent (Xcode Command Line Tools)
    if ! xcode-select -p &> /dev/null; then
        echo "Installing Xcode Command Line Tools..."
        xcode-select --install
        echo "Note: You may need to complete the installation in the GUI prompt"
    else
        echo "✓ Xcode Command Line Tools already installed"
    fi

    # gdb
    if ! command -v gdb &> /dev/null; then
        echo "Installing gdb..."
        brew install gdb
    else
        echo "✓ gdb already installed ($(gdb --version | head -n 1))"
    fi

    # python3 (usually pre-installed on macOS, but ensure it's available)
    if ! command -v python3 &> /dev/null; then
        echo "Installing python3..."
        brew install python3
    else
        echo "✓ python3 already installed ($(python3 --version))"
    fi

    # git
    if ! command -v git &> /dev/null; then
        echo "Installing git..."
        brew install git
    else
        echo "✓ git already installed ($(git --version))"
    fi

    # iproute2mac (equivalent to iproute2 on Linux)
    if ! command -v ip &> /dev/null; then
        echo "Installing iproute2mac..."
        brew install iproute2mac
    else
        echo "✓ iproute2mac already installed"
    fi

    echo ""
    echo "Note: On macOS, python3 comes with venv built-in"
    echo "Note: 'python' command may not be aliased to 'python3' by default"

elif command -v apt &> /dev/null; then
    # Ubuntu installation
    echo "Platform: Ubuntu"
    echo ""
    echo "Updating package list..."
    sudo apt update

    echo ""
    echo "Installing development tools..."

    # Install all packages at once
    sudo apt install -y \
        build-essential \
        gdb \
        python3-venv \
        python-is-python3 \
        git \
        iproute2 \
        zip \
        unzip

    echo ""
    echo "✓ All packages installed successfully"

else
    echo "Error: Unsupported platform. This script supports Ubuntu and macOS only."
    exit 1
fi

echo ""
echo "========================================"
echo "Installation Complete!"
echo "========================================"
echo ""
echo "Installed tools:"
if command -v brew &> /dev/null; then
    echo "  - Xcode Command Line Tools (build tools, compilers)"
else
    echo "  - build-essential (gcc, g++, make, etc.)"
fi
echo "  - gdb (debugger)"
echo "  - python3 with venv support"
if command -v apt &> /dev/null; then
    echo "  - python-is-python3 (python -> python3 alias)"
fi
echo "  - git (version control)"
if command -v brew &> /dev/null; then
    echo "  - iproute2mac (ip command for macOS)"
else
    echo "  - iproute2 (ip command)"
    echo "  - zip/unzip (archive utilities)"
fi
echo ""
echo "Verify installations:"
echo "  gcc --version"
echo "  gdb --version"
echo "  python --version"
echo "  python3 --version"
echo "  git --version"
echo "  ip --version"
