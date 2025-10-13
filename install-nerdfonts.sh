#!/bin/bash

# Nerd Fonts Installation Script
# Installs FiraCode Nerd Font to ~/.local without sudo permissions

set -e

echo "========================================"
echo "Nerd Fonts Installer"
echo "========================================"
echo ""

# Define font directory
FONT_DIR="$HOME/.local/share/fonts"

# Create font directory
echo "Creating font directory..."
mkdir -p "$FONT_DIR"

# Download Nerd Font
echo ""
echo "Downloading FiraCode Nerd Font..."
cd "$FONT_DIR"
FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/FiraCode.zip"

if command -v curl &> /dev/null; then
    curl -sL "$FONT_URL" -o FiraCode.zip
elif command -v wget &> /dev/null; then
    wget -q "$FONT_URL" -O FiraCode.zip
else
    echo "Error: Neither curl nor wget found. Please install one of them."
    exit 1
fi

echo "Extracting fonts..."
unzip -q FiraCode.zip
rm FiraCode.zip

echo "Updating font cache..."
fc-cache -fv "$FONT_DIR" > /dev/null 2>&1

echo ""
echo "✓ FiraCode Nerd Font installed to $FONT_DIR"
echo ""
echo "Font files installed:"
ls -1 "$FONT_DIR" | grep -i fira | head -5
echo ""
echo "Next: Configure your terminal to use 'FiraCode Nerd Font' or 'FiraCode Nerd Font Mono'"
echo ""