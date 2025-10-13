#!/bin/bash

# Uninstall Script for Starship and Nerd Fonts
# Removes all installed files and configurations

set -e

echo "========================================="
echo "  Starship & Nerd Fonts Uninstaller"
echo "========================================="
echo ""
echo "This script will remove:"
echo "  - Starship binary from ~/.local/bin"
echo "  - Starship configuration from ~/.config/starship.toml"
echo "  - Shell initialization lines from .bashrc/.zshrc"
echo ""
read -p "Do you also want to remove FiraCode Nerd Fonts? (y/N): " -n 1 -r REMOVE_FONTS
echo ""
echo ""
read -p "Are you sure you want to continue? (y/N): " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Uninstallation cancelled."
    exit 0
fi

echo ""
echo "Starting uninstallation..."
echo ""

# Remove Starship binary
if [ -f "$HOME/.local/bin/starship" ]; then
    echo "Removing Starship binary..."
    rm -f "$HOME/.local/bin/starship"
    echo "✓ Starship binary removed"
else
    echo "⊘ Starship binary not found (already removed or never installed)"
fi

# Remove Nerd Fonts (optional)
if [[ $REMOVE_FONTS =~ ^[Yy]$ ]]; then
    FONT_DIR="$HOME/.local/share/fonts"
    if [ -d "$FONT_DIR" ] && ls "$FONT_DIR"/FiraCode*.ttf >/dev/null 2>&1; then
        echo ""
        echo "Removing FiraCode Nerd Fonts..."
        rm -f "$FONT_DIR"/FiraCode*.ttf
        rm -f "$FONT_DIR"/FiraCode*.otf
        echo "✓ FiraCode Nerd Fonts removed"
        
        echo "Updating font cache..."
        fc-cache -fv "$FONT_DIR" > /dev/null 2>&1
        echo "✓ Font cache updated"
    else
        echo ""
        echo "⊘ FiraCode Nerd Fonts not found (already removed or never installed)"
    fi
else
    echo ""
    echo "⊘ Skipping Nerd Fonts removal (keeping installed)"
fi

# Remove Starship config
if [ -f "$HOME/.config/starship.toml" ]; then
    echo ""
    echo "Removing Starship configuration..."
    rm -f "$HOME/.config/starship.toml"
    echo "✓ Starship configuration removed"
else
    echo ""
    echo "⊘ Starship configuration not found (already removed or never installed)"
fi

# Remove Starship initialization from .bashrc
if [ -f "$HOME/.bashrc" ]; then
    echo ""
    echo "Cleaning Starship references from ~/.bashrc..."
    
    # Create backup first
    cp "$HOME/.bashrc" "$HOME/.bashrc.backup_$(date +%Y%m%d_%H%M%S)"
    
    # Remove all Starship-related lines including if blocks (more comprehensive cleanup)
    sed -i '/# Initialize Starship prompt/,/^fi$/d' "$HOME/.bashrc"
    sed -i '/^if command -v starship/,/^fi$/d' "$HOME/.bashrc"
    sed -i '/eval.*starship init bash/d' "$HOME/.bashrc"
    sed -i '/eval.*starship/d' "$HOME/.bashrc" 
    sed -i '/starship init/d' "$HOME/.bashrc"
    
    # Also remove PATH additions for ~/.local/bin if they were added by starship installer
    sed -i '/# Add ~\/\.local\/bin to PATH/d' "$HOME/.bashrc"
    sed -i '/export PATH="\$HOME\/\.local\/bin:\$PATH"/d' "$HOME/.bashrc"
    
    echo "✓ All Starship references removed from ~/.bashrc"
    echo "  (Backup created: ~/.bashrc.backup_*)"
fi

# Remove Starship initialization from .zshrc
if [ -f "$HOME/.zshrc" ]; then
    echo ""
    echo "Cleaning Starship references from ~/.zshrc..."
    
    # Create backup
    cp "$HOME/.zshrc" "$HOME/.zshrc.backup_$(date +%Y%m%d_%H%M%S)"
    
    # Remove all Starship-related lines including if blocks (more comprehensive cleanup)
    sed -i '/# Initialize Starship prompt/,/^fi$/d' "$HOME/.zshrc"
    sed -i '/^if command -v starship/,/^fi$/d' "$HOME/.zshrc"
    sed -i '/eval.*starship init zsh/d' "$HOME/.zshrc"
    sed -i '/eval.*starship/d' "$HOME/.zshrc"
    sed -i '/starship init/d' "$HOME/.zshrc"
    
    # Also remove PATH additions for ~/.local/bin if they were added by starship installer
    sed -i '/# Add ~\/\.local\/bin to PATH/d' "$HOME/.zshrc"
    sed -i '/export PATH="\$HOME\/\.local\/bin:\$PATH"/d' "$HOME/.zshrc"
    
    echo "✓ All Starship references removed from ~/.zshrc"
    echo "  (Backup created: ~/.zshrc.backup_*)"
fi

echo ""
echo "========================================="
echo "  Uninstallation Complete!"
echo "========================================="
echo ""
echo "Notes:"
echo "- ~/.local/bin directory was kept (may contain other programs)"
echo "- PATH configuration for ~/.local/bin was kept (may be used by other programs)"
echo "- Backups of modified shell configs were created"
echo ""
echo "To complete the cleanup:"
echo "1. IMPORTANT: Start a new terminal session (close current terminal and open new one)"
echo "2. Or run: exec bash (to restart bash in current session)"
echo "3. Change your terminal font back to default if needed"
echo ""
echo "Your bash prompt should now be back to default."
echo ""
echo "If you still see starship errors, manually edit ~/.bashrc and remove any remaining starship lines."
echo ""