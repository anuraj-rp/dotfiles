#!/bin/bash

# Starship Installation Script
# Installs Starship to ~/.local without sudo permissions

set -e

echo "========================================"
echo "Starship Prompt Installer"
echo "========================================"
echo ""

# Define installation directory
INSTALL_DIR="$HOME/.local/bin"
CONFIG_DIR="$HOME/.config"

# Create necessary directories
echo "Creating directories..."
mkdir -p "$INSTALL_DIR"
mkdir -p "$CONFIG_DIR"

# Download and install Starship
echo ""
echo "Downloading Starship..."
cd /tmp
STARSHIP_VERSION="1.19.0"
STARSHIP_URL="https://github.com/starship/starship/releases/download/v${STARSHIP_VERSION}/starship-x86_64-unknown-linux-gnu.tar.gz"

if command -v curl &> /dev/null; then
    curl -sL "$STARSHIP_URL" -o starship.tar.gz
elif command -v wget &> /dev/null; then
    wget -q "$STARSHIP_URL" -O starship.tar.gz
else
    echo "Error: Neither curl nor wget found. Please install one of them."
    exit 1
fi

echo "Extracting Starship..."
tar -xzf starship.tar.gz
mv starship "$INSTALL_DIR/"
chmod +x "$INSTALL_DIR/starship"
rm starship.tar.gz

echo "✓ Starship installed to $INSTALL_DIR/starship"

# Add to PATH if not already there
echo ""
echo "Checking PATH configuration..."

SHELL_CONFIG=""
if [ -n "$BASH_VERSION" ]; then
    SHELL_CONFIG="$HOME/.bashrc"
elif [ -n "$ZSH_VERSION" ]; then
    SHELL_CONFIG="$HOME/.zshrc"
else
    # Default to bashrc
    SHELL_CONFIG="$HOME/.bashrc"
fi

# Check if PATH already includes ~/.local/bin
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    echo "Adding ~/.local/bin to PATH in $SHELL_CONFIG"
    echo '' >> "$SHELL_CONFIG"
    echo '# Add ~/.local/bin to PATH' >> "$SHELL_CONFIG"
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$SHELL_CONFIG"
else
    echo "✓ ~/.local/bin already in PATH"
fi

# Add Starship initialization
echo ""
echo "Configuring shell integration..."

# For Bash
if [ -f "$HOME/.bashrc" ]; then
    if ! grep -q 'eval "$(starship init bash)"' "$HOME/.bashrc"; then
        echo '' >> "$HOME/.bashrc"
        echo '# Initialize Starship prompt' >> "$HOME/.bashrc"
        echo 'eval "$(starship init bash)"' >> "$HOME/.bashrc"
        echo "✓ Starship initialized in ~/.bashrc"
    else
        echo "✓ Starship already initialized in ~/.bashrc"
    fi
fi

# For Zsh (if exists)
if [ -f "$HOME/.zshrc" ]; then
    if ! grep -q 'eval "$(starship init zsh)"' "$HOME/.zshrc"; then
        echo '' >> "$HOME/.zshrc"
        echo '# Initialize Starship prompt' >> "$HOME/.zshrc"
        echo 'eval "$(starship init zsh)"' >> "$HOME/.zshrc"
        echo "✓ Starship initialized in ~/.zshrc"
    else
        echo "✓ Starship already initialized in ~/.zshrc"
    fi
fi

# Install Starship configuration
echo ""
echo "Installing Starship configuration..."
STARSHIP_CONFIG="$CONFIG_DIR/starship.toml"

if [ -f "$STARSHIP_CONFIG" ]; then
    echo "✓ Config file already exists at $STARSHIP_CONFIG (keeping existing)"
else
    echo "Installing Gruvbox Rainbow preset..."
    if "$INSTALL_DIR/starship" preset gruvbox-rainbow -o "$STARSHIP_CONFIG"; then
        echo "✓ Gruvbox Rainbow preset installed to $STARSHIP_CONFIG"
    else
        echo "⚠ Warning: Failed to install preset. Starship will use default configuration"
    fi
fi

echo ""
echo "========================================"
echo "Starship Installation Complete!"
echo "========================================"
echo ""
echo "Next steps:"
echo "1. Close and reopen your terminal (or run: source ~/.bashrc)"
echo "2. Verify installation: starship --version"
echo ""
echo "Configuration file: $STARSHIP_CONFIG"
echo "Style: Gruvbox Rainbow with colorful segments"
echo "To customize: https://starship.rs/config/"
echo "Enjoy your new prompt! 🚀"