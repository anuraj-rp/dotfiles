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

    if [ -L "$HOME/.fzfignore" ]; then
        rm "$HOME/.fzfignore"
        echo "Removed symlink: ~/.fzfignore"
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

    if [ -L "$HOME/.fzfignore" ]; then
        rm "$HOME/.fzfignore"
        echo "Removed symlink: ~/.fzfignore"
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

echo "Installing prerequisites (git, curl, fzf, fd, ripgrep, bat)..."

if command -v brew &> /dev/null; then
    # macOS
    brew install git curl fzf fd ripgrep bat 2>/dev/null || true
elif command -v apt &> /dev/null; then
    # Ubuntu (fd is named fd-find, bat is named batcat)
    sudo apt install -y git curl fzf fd-find ripgrep bat
    # Create fd alias if it doesn't exist
    if [ ! -f "$HOME/.local/bin/fd" ] && command -v fdfind &>/dev/null; then
        mkdir -p "$HOME/.local/bin"
        ln -sf "$(which fdfind)" "$HOME/.local/bin/fd"
        echo "Created symlink: fd -> fdfind"
    fi
    # Create bat alias if it doesn't exist
    if [ ! -f "$HOME/.local/bin/bat" ] && command -v batcat &>/dev/null; then
        mkdir -p "$HOME/.local/bin"
        ln -sf "$(which batcat)" "$HOME/.local/bin/bat"
        echo "Created symlink: bat -> batcat"
    fi
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

# Symlink fzfignore
FZFIGNORE="$SCRIPT_DIR/fzfignore"
if [ -f "$FZFIGNORE" ]; then
    if [ -L "$HOME/.fzfignore" ]; then
        rm "$HOME/.fzfignore"
    elif [ -f "$HOME/.fzfignore" ]; then
        mv "$HOME/.fzfignore" "$HOME/.fzfignore.backup"
    fi
    ln -s "$FZFIGNORE" "$HOME/.fzfignore"
    echo "Symlinked $FZFIGNORE to ~/.fzfignore"
fi

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
echo "  - fzf (fuzzy finder)"
echo "  - fd (fast file finder)"
echo "  - ripgrep (fast grep)"
echo "  - bat (syntax highlighted cat)"
echo "  - Plugins will be installed on first zsh launch:"
echo "    - Starship prompt (requires install-starship.sh)"
echo "    - FZF-Tab (tab completion with FZF)"
echo "    - zsh-autosuggestions"
echo "    - zsh-syntax-highlighting"
echo "    - git, sudo, cp OMZ snippets"
echo ""
echo "Next steps:"
echo "  1. Run install-starship.sh if not already installed"
echo "  2. Restart your terminal or run: exec zsh"
echo "  3. Wait for plugins to download on first launch"
echo ""
echo "Verify installation:"
echo "  - Prompt: Starship prompt should appear"
echo "  - Syntax Highlighting: Type 'echo test' (should be green)"
echo "  - FZF History: Press Ctrl+R"
echo "  - FZF Tab: Type 'cd ' and press Tab"
echo ""
echo "To clean up:"
echo "  $0 --clean      # Remove symlink only"
echo "  $0 --clean-all  # Remove symlink and zinit plugins"
