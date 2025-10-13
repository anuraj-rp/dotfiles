#!/bin/bash

# Starship Configuration Script
# Installs Gruvbox Rainbow preset and customizes directory display

set -e

echo "========================================"
echo "Starship Configuration"
echo "========================================"
echo ""

CONFIG_DIR="$HOME/.config"
STARSHIP_CONFIG="$CONFIG_DIR/starship.toml"
STARSHIP_BIN="$HOME/.local/bin/starship"

# Check if starship is installed
if [ ! -f "$STARSHIP_BIN" ]; then
    echo "Error: Starship is not installed at $STARSHIP_BIN. Please run install-starship.sh first."
    exit 1
fi

echo "Installing Gruvbox Rainbow preset..."
"$STARSHIP_BIN" preset gruvbox-rainbow -o "$STARSHIP_CONFIG"

if [ $? -ne 0 ]; then
    echo "Error: Failed to install Gruvbox Rainbow preset"
    exit 1
fi

echo "✓ Gruvbox Rainbow preset installed"

# Patch the directory configuration to show abbreviated paths
echo ""
echo "Configuring abbreviated directory paths..."

# Update the [directory] section to enable fish-style abbreviation
# NOTE: fish_style_pwd_dir_length doesn't work with [directory.substitutions]
# See: https://github.com/starship/starship/issues/2060
# Use truncation_length = 1 which forces fish-style abbreviation to work
sed -i '/^\[directory\]/,/^\[/ {
    s/truncation_length = 3/truncation_length = 1/
    /fish_style_pwd_dir_length = 1/d
    /truncate_to_repo = false/d
    /^truncation_symbol = /a\
fish_style_pwd_dir_length = 1\
truncate_to_repo = false
}' "$STARSHIP_CONFIG"

# Remove the [directory.substitutions] section as it conflicts with fish_style_pwd_dir_length
# This removes the section header and all its key-value pairs until the next section or end of file
sed -i '/^\[directory\.substitutions\]/,/^\[/{ /^\[directory\.substitutions\]/d; /^\[/!d; }' "$STARSHIP_CONFIG"

# Disable username display (only show OS icon)
sed -i '/^\[username\]/,/^\[/ {
    s/show_always = true/show_always = false/
}' "$STARSHIP_CONFIG"

echo "✓ Directory paths configured to show first letter (e.g., ~/s/g/dotfiles)"
echo "✓ Username display disabled (only OS icon will show)"

echo ""
echo "========================================"
echo "Configuration Complete!"
echo "========================================"
echo ""
echo "Your prompt will now show:"
echo "  - Abbreviated paths like ~/s/g/dotfiles"
echo "  - Gruvbox Rainbow color scheme"
echo "  - All programming language indicators"
echo ""
echo "Reload your shell to see changes: source ~/.bashrc"
echo ""
