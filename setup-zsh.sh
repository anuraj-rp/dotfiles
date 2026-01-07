#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ZSHRC="$SCRIPT_DIR/zshrc"

# Clean mode: remove configuration symlinks
if [ "$1" == "--clean" ]; then
    echo "Cleaning up zsh configuration..."

    if [ -L "$HOME/.zshrc" ]; then
        rm "$HOME/.zshrc"
        echo "Removed symlink: ~/.zshrc"
    else
        echo "No symlink found at ~/.zshrc"
    fi

    echo "Cleanup complete!"
    exit 0
fi

# Clean all mode: remove configuration symlinks and plugins
if [ "$1" == "--clean-all" ]; then
    echo "Cleaning up zsh configuration and plugins..."

    if [ -L "$HOME/.zshrc" ]; then
        rm "$HOME/.zshrc"
        echo "Removed symlink: ~/.zshrc"
    else
        echo "No symlink found at ~/.zshrc"
    fi

    ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit"
    if [ -d "$ZINIT_HOME" ]; then
        rm -rf "$ZINIT_HOME"
        echo "Removed zinit directory: $ZINIT_HOME"
    else
        echo "No zinit directory found at $ZINIT_HOME"
    fi

    if [ -f "$HOME/.zsh_history" ]; then
        echo "Note: ~/.zsh_history preserved (remove manually if desired)"
    fi

    echo "Full cleanup complete!"
    exit 0
fi

echo "Installing zsh..."

if command -v zsh &> /dev/null; then
    echo "zsh is already installed ($(zsh --version))"
else
    if command -v brew &> /dev/null; then
        brew install zsh
        echo "zsh installed successfully"
    elif command -v apt &> /dev/null; then
        sudo apt update
        sudo apt install -y zsh
        echo "zsh installed successfully"
    else
        echo "Error: Unsupported platform. This script supports Ubuntu and macOS only."
        exit 1
    fi
fi

echo "Installing prerequisites (git, curl, fzf)..."

if command -v brew &> /dev/null; then
    # macOS
    brew install git curl fzf 2>/dev/null || true
elif command -v apt &> /dev/null; then
    # Ubuntu
    sudo apt install -y git curl fzf
fi

echo "Installing Zinit plugin manager..."

ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

if [ -d "$ZINIT_HOME/.git" ]; then
    echo "Zinit already installed, updating..."
    git -C "$ZINIT_HOME" pull
else
    mkdir -p "$(dirname "$ZINIT_HOME")"
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
    echo "Zinit installed successfully"
fi

echo "Setting up zsh configuration..."

if [ ! -f "$ZSHRC" ]; then
    echo "Error: zshrc not found in $SCRIPT_DIR"
    exit 1
fi

if [ -L "$HOME/.zshrc" ]; then
    echo "Removing existing symlink at ~/.zshrc"
    rm "$HOME/.zshrc"
elif [ -f "$HOME/.zshrc" ]; then
    echo "Backing up existing ~/.zshrc to ~/.zshrc.backup"
    mv "$HOME/.zshrc" "$HOME/.zshrc.backup"
fi

ln -s "$ZSHRC" "$HOME/.zshrc"
echo "Symlinked $ZSHRC to ~/.zshrc"

# Set zsh as default shell
ZSH_PATH=$(which zsh)
if [ "$SHELL" != "$ZSH_PATH" ]; then
    echo ""
    echo "Setting zsh as default shell..."

    # Ensure zsh is in /etc/shells
    if ! grep -q "$ZSH_PATH" /etc/shells 2>/dev/null; then
        echo "Adding $ZSH_PATH to /etc/shells"
        echo "$ZSH_PATH" | sudo tee -a /etc/shells
    fi

    chsh -s "$ZSH_PATH"
    echo "Default shell changed to zsh (will take effect on next login)"
else
    echo "zsh is already the default shell"
fi

echo ""
echo "zsh setup complete!"
echo ""
echo "Installed components:"
echo "  - zsh"
echo "  - Zinit (plugin manager)"
echo "  - Plugins will be installed on first zsh launch:"
echo "    - RobbyRussell theme"
echo "    - FZF (fuzzy finder)"
echo "    - FZF-Tab (tab completion with FZF)"
echo "    - zsh-autosuggestions"
echo "    - zsh-syntax-highlighting"
echo "    - git, sudo, cp OMZ snippets"
echo ""
echo "Next steps:"
echo "  1. Restart your terminal or run: exec zsh"
echo "  2. Wait for plugins to download on first launch"
echo ""
echo "Verify installation:"
echo "  - Theme: You should see the green arrow prompt"
echo "  - Syntax Highlighting: Type 'echo test' (should be green)"
echo "  - FZF History: Press Ctrl+R"
echo "  - FZF Tab: Type 'cd ' and press Tab"
echo ""
echo "To clean up:"
echo "  $0 --clean      # Remove symlink only"
echo "  $0 --clean-all  # Remove symlink and zinit plugins"
