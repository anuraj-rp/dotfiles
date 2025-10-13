#!/bin/bash

# Master Installation Script
# Installs both Nerd Fonts and Starship

set -e

echo "========================================="
echo "  Starship & Nerd Fonts Setup"
echo "========================================="
echo ""
echo "This script will:"
echo "  1. Install FiraCode Nerd Font"
echo "  2. Install Starship prompt"
echo ""
echo "All installations will be in ~/.local (no sudo required)"
echo ""

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check if individual scripts exist
if [ ! -f "$SCRIPT_DIR/install-nerdfonts.sh" ]; then
    echo "Error: install-nerdfonts.sh not found in $SCRIPT_DIR"
    exit 1
fi

if [ ! -f "$SCRIPT_DIR/install-starship.sh" ]; then
    echo "Error: install-starship.sh not found in $SCRIPT_DIR"
    exit 1
fi

# Make scripts executable
chmod +x "$SCRIPT_DIR/install-nerdfonts.sh"
chmod +x "$SCRIPT_DIR/install-starship.sh"

# Run font installation
echo "========================================="
echo "Step 1/2: Installing Nerd Fonts"
echo "========================================="
echo ""
bash "$SCRIPT_DIR/install-nerdfonts.sh"

if [ $? -ne 0 ]; then
    echo ""
    echo "Error: Font installation failed!"
    exit 1
fi

echo ""
read -p "Press Enter to continue with Starship installation..."
echo ""

# Run Starship installation
echo "========================================="
echo "Step 2/2: Installing Starship"
echo "========================================="
echo ""
bash "$SCRIPT_DIR/install-starship.sh"

if [ $? -ne 0 ]; then
    echo ""
    echo "Error: Starship installation failed!"
    exit 1
fi

# Final instructions
echo ""
echo "========================================="
echo "  Installation Complete! 🚀"
echo "========================================="
echo ""
echo "IMPORTANT: Complete the setup by:"
echo ""
echo "1. Reload your shell configuration:"
echo "   source ~/.bashrc"
echo ""
echo "2. Configure your terminal emulator:"
echo "   - Open terminal preferences/settings"
echo "   - Change font to 'FiraCode Nerd Font' or 'FiraCode Nerd Font Mono'"
echo "   - Restart your terminal"
echo ""
echo "3. Verify installation:"
echo "   starship --version"
echo ""
echo "Configuration file: ~/.config/starship.toml"
echo "Customize your prompt: https://starship.rs/config/"
echo ""
echo "Enjoy your new prompt! ✨"
echo ""