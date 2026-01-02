#!/usr/bin/env bash
# install-nodejs.sh — Install Node.js via nvm and pnpm
# Safe to run multiple times.

set -e

# Clean mode: remove nvm and node
if [ "$1" == "--clean" ]; then
    echo "Cleaning up Node.js environment..."

    # Disable any running node processes handled by nvm
    echo "Note: This will not uninstall Node.js, only remove shell integration"

    # Remove nvm initialization from shell configs
    for config in "$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.bash_profile"; do
        if [ -f "$config" ]; then
            sed -i.bak '/export NVM_DIR/d' "$config"
            sed -i.bak '/\[ -s ".*nvm\.sh" \]/d' "$config"
            sed -i.bak '/\[ -s ".*bash_completion" \]/d' "$config"
            rm -f "${config}.bak"
            echo "Removed nvm from $config"
        fi
    done

    echo "Cleanup complete! (nvm and Node.js still installed)"
    echo "To completely remove, run: $0 --clean-all"
    exit 0
fi

# Clean all mode: uninstall nvm and node completely
if [ "$1" == "--clean-all" ]; then
    echo "Completely removing nvm and Node.js..."

    # Remove nvm initialization from shell configs
    for config in "$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.bash_profile"; do
        if [ -f "$config" ]; then
            sed -i.bak '/export NVM_DIR/d' "$config"
            sed -i.bak '/\[ -s ".*nvm\.sh" \]/d' "$config"
            sed -i.bak '/\[ -s ".*bash_completion" \]/d' "$config"
            rm -f "${config}.bak"
            echo "Removed nvm from $config"
        fi
    done

    # Remove nvm directory
    if [ -d "$HOME/.nvm" ]; then
        rm -rf "$HOME/.nvm"
        echo "Removed ~/.nvm directory"
    fi

    # Remove npm cache
    if [ -d "$HOME/.npm" ]; then
        rm -rf "$HOME/.npm"
        echo "Removed ~/.npm cache"
    fi

    echo "Full uninstall complete!"
    exit 0
fi

echo "========================================"
echo "Node.js Installer (via nvm)"
echo "========================================"
echo ""

# Check if nvm is already installed
if [ -d "$HOME/.nvm" ]; then
    echo "nvm is already installed at ~/.nvm"

    # Load nvm for this session
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

    if command -v nvm &> /dev/null; then
        echo "nvm version: $(nvm --version)"
    fi
else
    echo "Installing nvm..."

    # Download and install nvm
    NVM_VERSION="v0.40.3"
    curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh" | bash

    # Load nvm for this session
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

    echo "✓ nvm installed successfully"
fi

echo ""
echo "Installing Node.js..."

# Check if Node.js 24 is already installed
if command -v node &> /dev/null; then
    CURRENT_VERSION=$(node -v)
    echo "Node.js is already installed: $CURRENT_VERSION"

    # Check if it's version 24
    if [[ "$CURRENT_VERSION" == v24.* ]]; then
        echo "✓ Node.js 24 is already active"
    else
        echo "Installing Node.js 24..."
        nvm install 24
        nvm use 24
        nvm alias default 24
        echo "✓ Node.js 24 installed and set as default"
    fi
else
    echo "Installing Node.js 24..."
    nvm install 24
    nvm use 24
    nvm alias default 24
    echo "✓ Node.js 24 installed and set as default"
fi

# Verify Node.js installation
NODE_VERSION=$(node -v)
echo ""
echo "Node.js version: $NODE_VERSION"
echo "npm version: $(npm -v)"

echo ""
echo "Installing pnpm..."

# Enable corepack and install pnpm
if command -v corepack &> /dev/null; then
    corepack enable pnpm
    echo "✓ pnpm enabled via corepack"

    # Verify pnpm installation
    if command -v pnpm &> /dev/null; then
        echo "pnpm version: $(pnpm -v)"
    else
        echo "⚠ Warning: pnpm enabled but not available in PATH. Restart your shell."
    fi
else
    echo "⚠ Warning: corepack not found. Install pnpm manually with: npm install -g pnpm"
fi

echo ""
echo "========================================"
echo "Node.js Setup Complete!"
echo "========================================"
echo ""
echo "Installed:"
echo "  ✓ nvm $(nvm --version)"
echo "  ✓ Node.js $NODE_VERSION"
echo "  ✓ npm $(npm -v)"
if command -v pnpm &> /dev/null; then
    echo "  ✓ pnpm $(pnpm -v)"
fi
echo ""
echo "Next steps:"
echo "  1. Restart your shell (or run: source ~/.bashrc)"
echo "  2. Verify installation: node -v && pnpm -v"
echo ""
echo "Useful nvm commands:"
echo "  nvm install <version>  # Install a specific Node version"
echo "  nvm use <version>      # Switch to a specific version"
echo "  nvm ls                 # List installed versions"
echo "  nvm alias default <v>  # Set default version"
echo ""
echo "To clean up:"
echo "  $0 --clean      # Remove shell integration only"
echo "  $0 --clean-all  # Completely uninstall nvm and Node.js"
echo ""
