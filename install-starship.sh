#!/bin/bash

# Starship Installation Script
# Installs Starship (Ubuntu and macOS)

set -e

# Clean mode: remove shell integration
if [ "$1" == "--clean" ]; then
    echo "Cleaning up starship shell integration..."

    # Remove from all shell config files
    for config in "$HOME/.bashrc" "$HOME/.bash_profile" "$HOME/.profile" "$HOME/.zshrc"; do
        if [ -f "$config" ]; then
            sed -i.bak '/# Initialize Starship prompt/d' "$config"
            sed -i.bak '/eval "$(starship init bash)"/d' "$config"
            sed -i.bak '/eval "$(starship init zsh)"/d' "$config"
            sed -i.bak '/starship init/d' "$config"
            rm -f "${config}.bak"
            echo "Removed starship from $config"
        fi
    done

    echo "Cleanup complete! (starship binary still installed)"
    exit 0
fi

# Clean all mode: uninstall completely
if [ "$1" == "--clean-all" ]; then
    echo "Completely removing starship..."

    # Remove shell integration from all shell config files
    for config in "$HOME/.bashrc" "$HOME/.bash_profile" "$HOME/.profile" "$HOME/.zshrc"; do
        if [ -f "$config" ]; then
            sed -i.bak '/# Initialize Starship prompt/d' "$config"
            sed -i.bak '/eval "$(starship init bash)"/d' "$config"
            sed -i.bak '/eval "$(starship init zsh)"/d' "$config"
            sed -i.bak '/starship init/d' "$config"
            sed -i.bak '/# Add ~\/.local\/bin to PATH/d' "$config"
            sed -i.bak '/export PATH="\$HOME\/.local\/bin:\$PATH"/d' "$config"
            rm -f "${config}.bak"
            echo "Removed starship from $config"
        fi
    done

    if command -v brew &> /dev/null; then
        # macOS uninstall
        brew uninstall starship
        echo "Uninstalled starship"
    else
        # Ubuntu uninstall
        if [ -f "$HOME/.local/bin/starship" ]; then
            rm "$HOME/.local/bin/starship"
            echo "Removed starship binary"
        fi
    fi

    # Remove config
    if [ -f "$HOME/.config/starship.toml" ]; then
        rm "$HOME/.config/starship.toml"
        echo "Removed starship config"
    fi

    echo "Full uninstall complete!"
    exit 0
fi

echo "========================================"
echo "Starship Prompt Installer"
echo "========================================"
echo ""

# Define installation directory
CONFIG_DIR="$HOME/.config"
mkdir -p "$CONFIG_DIR"

echo "Installing starship..."

if command -v starship &> /dev/null; then
    echo "starship is already installed ($(starship --version))"
else
    if command -v brew &> /dev/null; then
        # macOS installation
        brew install starship
        echo "starship installed successfully"
    elif command -v apt &> /dev/null; then
        # Ubuntu installation
        INSTALL_DIR="$HOME/.local/bin"
        mkdir -p "$INSTALL_DIR"

        echo "Downloading Starship..."
        TEMP_DIR=$(mktemp -d)
        cd "$TEMP_DIR"

        # Get latest version from GitHub API
        STARSHIP_VERSION=$(curl -s https://api.github.com/repos/starship/starship/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")' || echo "v1.24.2")

        # Detect architecture
        ARCH=$(uname -m)
        case "$ARCH" in
            x86_64)
                STARSHIP_ARCH="x86_64-unknown-linux-gnu"
                ;;
            aarch64|arm64)
                STARSHIP_ARCH="aarch64-unknown-linux-musl"
                ;;
            armv7l)
                STARSHIP_ARCH="arm-unknown-linux-musleabihf"
                ;;
            *)
                echo "Error: Unsupported architecture: $ARCH"
                exit 1
                ;;
        esac

        STARSHIP_URL="https://github.com/starship/starship/releases/download/${STARSHIP_VERSION}/starship-${STARSHIP_ARCH}.tar.gz"
        echo "Detected architecture: $ARCH (downloading $STARSHIP_ARCH)"
        echo "Version: $STARSHIP_VERSION"

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
        cd -
        rm -rf "$TEMP_DIR"

        echo "✓ Starship installed to $INSTALL_DIR/starship"

        # Add to PATH if not already there
        SHELL_CONFIG=""
        if [ -n "$BASH_VERSION" ]; then
            SHELL_CONFIG="$HOME/.bashrc"
        elif [ -n "$ZSH_VERSION" ]; then
            SHELL_CONFIG="$HOME/.zshrc"
        else
            SHELL_CONFIG="$HOME/.bashrc"
        fi

        if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
            echo "Adding ~/.local/bin to PATH in $SHELL_CONFIG"
            echo '' >> "$SHELL_CONFIG"
            echo '# Add ~/.local/bin to PATH' >> "$SHELL_CONFIG"
            echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$SHELL_CONFIG"
        else
            echo "✓ ~/.local/bin already in PATH"
        fi
    else
        echo "Error: Unsupported platform. This script supports Ubuntu and macOS only."
        exit 1
    fi
fi

# Add Starship initialization
echo ""
echo "Configuring shell integration..."

# Ensure .bashrc is sourced from .bash_profile for login shells (SSH)
if [ -f "$HOME/.bashrc" ]; then
    if [ -f "$HOME/.bash_profile" ]; then
        if ! grep -q "source.*\.bashrc" "$HOME/.bash_profile" && ! grep -q "\..*\.bashrc" "$HOME/.bash_profile"; then
            echo "Adding .bashrc source to .bash_profile for SSH sessions"
            echo '' >> "$HOME/.bash_profile"
            echo '# Source .bashrc for interactive shells' >> "$HOME/.bash_profile"
            echo 'if [ -f ~/.bashrc ]; then' >> "$HOME/.bash_profile"
            echo '    . ~/.bashrc' >> "$HOME/.bash_profile"
            echo 'fi' >> "$HOME/.bash_profile"
        fi
    elif [ ! -f "$HOME/.bash_profile" ]; then
        # Create .bash_profile if it doesn't exist
        echo "Creating .bash_profile to source .bashrc"
        cat > "$HOME/.bash_profile" <<'PROFILE_EOF'
# Source .bashrc for interactive shells
if [ -f ~/.bashrc ]; then
    . ~/.bashrc
fi
PROFILE_EOF
    fi
fi

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

    # Determine starship binary location
    if command -v brew &> /dev/null; then
        STARSHIP_BIN="starship"
    elif [ -f "$HOME/.local/bin/starship" ]; then
        STARSHIP_BIN="$HOME/.local/bin/starship"
    else
        STARSHIP_BIN="starship"
    fi

    if "$STARSHIP_BIN" preset gruvbox-rainbow -o "$STARSHIP_CONFIG" 2>/dev/null; then
        echo "✓ Gruvbox Rainbow preset installed to $STARSHIP_CONFIG"
    else
        echo "⚠ Warning: Failed to install preset. Starship will use default configuration"
        echo "  Run this after reloading shell: starship preset gruvbox-rainbow -o ~/.config/starship.toml"
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
echo ""
echo "To clean up:"
echo "  $0 --clean      # Remove shell integration only"
echo "  $0 --clean-all  # Completely uninstall starship"