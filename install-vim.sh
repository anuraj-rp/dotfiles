#!/bin/bash

set -e

# Clean mode: remove configuration symlinks
if [ "$1" == "--clean" ]; then
    echo "Cleaning up vim configuration..."

    if [ -L "$HOME/.vimrc" ]; then
        rm "$HOME/.vimrc"
        echo "Removed symlink: ~/.vimrc"
    else
        echo "No symlink found at ~/.vimrc"
    fi

    echo "Cleanup complete!"
    exit 0
fi

# Clean all mode: remove configuration symlinks and plugins
if [ "$1" == "--clean-all" ]; then
    echo "Cleaning up vim configuration and plugins..."

    if [ -L "$HOME/.vimrc" ]; then
        rm "$HOME/.vimrc"
        echo "Removed symlink: ~/.vimrc"
    else
        echo "No symlink found at ~/.vimrc"
    fi

    if [ -d "$HOME/.vim" ]; then
        rm -rf "$HOME/.vim"
        echo "Removed vim plugins directory: ~/.vim"
    else
        echo "No vim plugins directory found at ~/.vim"
    fi

    echo "Full cleanup complete!"
    exit 0
fi

echo "Installing vim..."

if command -v vim &> /dev/null; then
    echo "vim is already installed ($(vim --version | head -n 1))"
else
    if command -v brew &> /dev/null; then
        brew install vim
        echo "vim installed successfully"
    elif command -v apt &> /dev/null; then
        sudo apt update
        sudo apt install -y vim
        echo "vim installed successfully"
    else
        echo "Error: Unsupported platform. This script supports Ubuntu and macOS only."
        exit 1
    fi
fi

echo "Setting up vim configuration..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VIMRC="$SCRIPT_DIR/vimrc"

if [ ! -f "$VIMRC" ]; then
    echo "Error: vimrc not found in $SCRIPT_DIR"
    exit 1
fi

if [ -L "$HOME/.vimrc" ]; then
    echo "Removing existing symlink at ~/.vimrc"
    rm "$HOME/.vimrc"
elif [ -f "$HOME/.vimrc" ]; then
    echo "Backing up existing ~/.vimrc to ~/.vimrc.backup"
    mv "$HOME/.vimrc" "$HOME/.vimrc.backup"
fi

ln -s "$VIMRC" "$HOME/.vimrc"
echo "Symlinked $VIMRC to ~/.vimrc"

echo "Installing Vundle (vim plugin manager)..."
if [ -d "$HOME/.vim/bundle/Vundle.vim" ]; then
    echo "Vundle already installed, updating..."
    cd "$HOME/.vim/bundle/Vundle.vim"
    git pull
else
    mkdir -p "$HOME/.vim/bundle"
    git clone https://github.com/VundleVim/Vundle.vim.git "$HOME/.vim/bundle/Vundle.vim"
    echo "Vundle installed successfully"
fi

echo "Installing vim plugins..."
vim +PluginInstall +qall

echo ""
echo "vim setup complete!"
echo ""
echo "Installed plugins:"
echo "  - Vundle (plugin manager)"
echo "  - Dracula theme"
echo "  - Solarized theme"
echo "  - OneDark theme (active)"
echo "  - Python syntax highlighting"
echo "  - vim-fugitive (git integration)"
echo "  - vim-airline (statusline)"
echo "  - NERDTree (file explorer)"
echo ""
echo "To open NERDTree: :NERDTree"
echo "To toggle background: F5"
echo ""
echo "To clean up:"
echo "  $0 --clean      # Remove symlink only"
echo "  $0 --clean-all  # Remove symlink and all plugins"
