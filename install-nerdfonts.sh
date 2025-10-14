#!/bin/bash

# Nerd Fonts Installation Script
# Installs FiraMono Nerd Font to ~/.local without sudo permissions

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
echo "Downloading FiraMono Nerd Font..."
cd "$FONT_DIR"
FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/FiraMono.zip"

if command -v curl &> /dev/null; then
    curl -sL "$FONT_URL" -o FiraMono.zip
elif command -v wget &> /dev/null; then
    wget -q "$FONT_URL" -O FiraMono.zip
else
    echo "Error: Neither curl nor wget found. Please install one of them."
    exit 1
fi

echo "Extracting fonts..."
unzip -q FiraMono.zip
rm FiraMono.zip

echo "Updating font cache..."
fc-cache -fv "$FONT_DIR" > /dev/null 2>&1

echo ""
echo "✓ FiraMono Nerd Font installed to $FONT_DIR"
echo ""
echo "Font files installed:"
ls -1 "$FONT_DIR" | grep -i fira | head -5
echo ""
echo "Next steps:"
echo "1. Configure your terminal to use 'FiraMono Nerd Font' (monospace variant)"
echo "2. If using VS Code, restart VS Code completely for the font to be recognized"
echo "3. Set VS Code terminal font: Settings > Terminal > Font Family > 'FiraMono Nerd Font'"
echo ""