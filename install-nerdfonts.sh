#!/bin/bash

# Nerd Fonts Installation Script
# Installs FiraMono Nerd Font (Ubuntu and macOS)

set -e

# Clean mode: remove font files
if [ "$1" == "--clean" ] || [ "$1" == "--clean-all" ]; then
    echo "Cleaning up FiraMono Nerd Font..."

    if command -v brew &> /dev/null; then
        # macOS cleanup
        FONT_DIR="$HOME/Library/Fonts"
    else
        # Ubuntu cleanup
        FONT_DIR="$HOME/.local/share/fonts"
    fi

    if [ -d "$FONT_DIR" ]; then
        rm -f "$FONT_DIR"/FiraMono*.ttf "$FONT_DIR"/FiraMono*.otf 2>/dev/null || true
        echo "Removed FiraMono font files from $FONT_DIR"

        if ! command -v brew &> /dev/null; then
            fc-cache -fv "$FONT_DIR" > /dev/null 2>&1
            echo "Updated font cache"
        fi
    fi

    echo "Cleanup complete!"
    exit 0
fi

echo "========================================"
echo "Nerd Fonts Installer"
echo "========================================"
echo ""

# Define font directory based on platform
if command -v brew &> /dev/null; then
    # macOS
    FONT_DIR="$HOME/Library/Fonts"
    echo "Platform: macOS"
elif command -v apt &> /dev/null; then
    # Ubuntu
    FONT_DIR="$HOME/.local/share/fonts"
    echo "Platform: Ubuntu"
else
    echo "Error: Unsupported platform. This script supports Ubuntu and macOS only."
    exit 1
fi

# Check if unzip is available
if ! command -v unzip &> /dev/null; then
    echo "Error: unzip is not installed. Please run ./install-tools.sh first."
    exit 1
fi

# Create font directory
echo "Creating font directory..."
mkdir -p "$FONT_DIR"

# Download Nerd Font
echo ""
echo "Downloading FiraMono Nerd Font..."
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"
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
unzip -q FiraMono.zip || { echo "Error: Failed to extract fonts"; exit 1; }

# Move font files (some archives may only have .ttf or only .otf)
if ls *.ttf 1> /dev/null 2>&1; then
    mv *.ttf "$FONT_DIR/" 2>/dev/null || true
fi
if ls *.otf 1> /dev/null 2>&1; then
    mv *.otf "$FONT_DIR/" 2>/dev/null || true
fi

cd - > /dev/null
rm -rf "$TEMP_DIR"

echo "Updating font cache..."
if command -v brew &> /dev/null; then
    echo "Font installed to $FONT_DIR (macOS will auto-detect)"
else
    if command -v fc-cache &> /dev/null; then
        fc-cache -fv "$FONT_DIR" > /dev/null 2>&1 || echo "⚠ Warning: fc-cache failed, but fonts are installed"
        echo "✓ Font cache updated"
    else
        echo "⚠ Warning: fc-cache not found, skipping cache update"
        echo "  Install fontconfig if needed: sudo apt install fontconfig"
    fi
fi

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
echo "To clean up:"
echo "  $0 --clean      # Remove FiraMono font files"
echo "  $0 --clean-all  # Remove FiraMono font files"