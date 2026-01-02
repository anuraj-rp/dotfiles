#!/bin/bash

set -e

# Clean mode: remove configuration symlinks
if [ "$1" == "--clean" ]; then
    echo "Cleaning up tmux configuration..."

    if [ -L "$HOME/.tmux.conf" ]; then
        rm "$HOME/.tmux.conf"
        echo "Removed symlink: ~/.tmux.conf"
    else
        echo "No symlink found at ~/.tmux.conf"
    fi

    echo "Cleanup complete!"
    exit 0
fi

# Clean all mode: remove configuration symlinks and plugins
if [ "$1" == "--clean-all" ]; then
    echo "Cleaning up tmux configuration and plugins..."

    if [ -L "$HOME/.tmux.conf" ]; then
        rm "$HOME/.tmux.conf"
        echo "Removed symlink: ~/.tmux.conf"
    else
        echo "No symlink found at ~/.tmux.conf"
    fi

    if [ -d "$HOME/.tmux" ]; then
        rm -rf "$HOME/.tmux"
        echo "Removed tmux plugins directory: ~/.tmux"
    else
        echo "No tmux plugins directory found at ~/.tmux"
    fi

    echo "Full cleanup complete!"
    exit 0
fi

echo "Installing tmux..."

if command -v tmux &> /dev/null; then
    echo "tmux is already installed ($(tmux -V))"
else
    if command -v brew &> /dev/null; then
        brew install tmux
        echo "tmux installed successfully"
    elif command -v apt &> /dev/null; then
        sudo apt update
        sudo apt install -y tmux
        echo "tmux installed successfully"
    else
        echo "Error: Unsupported platform. This script supports Ubuntu and macOS only."
        exit 1
    fi
fi

echo "Setting up tmux configuration..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TMUX_CONF="$SCRIPT_DIR/tmux.conf"

if [ ! -f "$TMUX_CONF" ]; then
    echo "Error: tmux.conf not found in $SCRIPT_DIR"
    exit 1
fi

if [ -L "$HOME/.tmux.conf" ]; then
    echo "Removing existing symlink at ~/.tmux.conf"
    rm "$HOME/.tmux.conf"
elif [ -f "$HOME/.tmux.conf" ]; then
    echo "Backing up existing ~/.tmux.conf to ~/.tmux.conf.backup"
    mv "$HOME/.tmux.conf" "$HOME/.tmux.conf.backup"
fi

ln -s "$TMUX_CONF" "$HOME/.tmux.conf"
echo "Symlinked $TMUX_CONF to ~/.tmux.conf"

echo "Installing TPM (Tmux Plugin Manager)..."
if [ -d "$HOME/.tmux/plugins/tpm" ]; then
    echo "TPM already installed, updating..."
    cd "$HOME/.tmux/plugins/tpm"
    git pull
else
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
    echo "TPM installed successfully"
fi

echo ""
echo "tmux setup complete!"
echo ""
echo "To install tmux plugins:"
echo "  1. Start tmux: tmux"
echo "  2. Press prefix + I (Ctrl+a then Shift+i) to fetch and install plugins"
echo ""
echo "To reload tmux config in an existing session:"
echo "  Press prefix + r (Ctrl+a then r)"
echo ""
echo "To clean up:"
echo "  $0 --clean      # Remove symlink only"
echo "  $0 --clean-all  # Remove symlink and all plugins"
