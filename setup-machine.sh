#!/bin/bash

# Master Setup Script
# Orchestrates installation of all development tools and configurations
# Order: system tools -> git/python -> tmux/vim -> docker/networking -> tailscale

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Clean mode: clean all installations
if [ "$1" == "--clean" ]; then
    echo -e "${YELLOW}========================================"
    echo "Cleaning up all configurations..."
    echo -e "========================================${NC}"
    echo ""

    echo -e "${BLUE}[1/5] Cleaning tmux...${NC}"
    "$SCRIPT_DIR/install-tmux.sh" --clean || true

    echo ""
    echo -e "${BLUE}[2/5] Cleaning vim...${NC}"
    "$SCRIPT_DIR/install-vim.sh" --clean || true

    echo ""
    echo -e "${BLUE}[3/5] Cleaning docker...${NC}"
    "$SCRIPT_DIR/install-docker.sh" --clean || true

    echo ""
    echo -e "${BLUE}[4/5] Cleaning tailscale...${NC}"
    "$SCRIPT_DIR/install-tailscale.sh" --clean || true

    echo ""
    echo -e "${BLUE}[5/5] Cleaning starship...${NC}"
    "$SCRIPT_DIR/install-starship.sh" --clean || true

    echo ""
    echo -e "${GREEN}========================================"
    echo "Cleanup complete!"
    echo -e "========================================${NC}"
    echo ""
    echo "Services stopped/disabled. Software packages remain installed."
    echo "To fully uninstall, run: $0 --clean-all"
    exit 0
fi

# Clean all mode: uninstall everything
if [ "$1" == "--clean-all" ]; then
    echo -e "${RED}========================================"
    echo "FULL UNINSTALL - Removing all software..."
    echo -e "========================================${NC}"
    echo ""

    read -p "Are you sure you want to completely uninstall everything? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 0
    fi

    echo ""
    echo -e "${BLUE}[1/6] Uninstalling tmux...${NC}"
    "$SCRIPT_DIR/install-tmux.sh" --clean-all || true

    echo ""
    echo -e "${BLUE}[2/6] Uninstalling vim...${NC}"
    "$SCRIPT_DIR/install-vim.sh" --clean-all || true

    echo ""
    echo -e "${BLUE}[3/6] Uninstalling docker...${NC}"
    "$SCRIPT_DIR/install-docker.sh" --clean-all || true

    echo ""
    echo -e "${BLUE}[4/6] Uninstalling tailscale...${NC}"
    "$SCRIPT_DIR/install-tailscale.sh" --clean-all || true

    echo ""
    echo -e "${BLUE}[5/6] Uninstalling starship...${NC}"
    "$SCRIPT_DIR/install-starship.sh" --clean-all || true

    echo ""
    echo -e "${BLUE}[6/6] Uninstalling nerd fonts...${NC}"
    "$SCRIPT_DIR/install-nerdfonts.sh" --clean-all || true

    echo ""
    echo -e "${GREEN}========================================"
    echo "Full uninstall complete!"
    echo -e "========================================${NC}"
    echo ""
    echo "Note: System development tools (build-essential, git, python, etc.) were not removed."
    echo "To remove them, use your package manager directly."
    exit 0
fi

# Main installation sequence
echo -e "${GREEN}========================================"
echo "Master Setup Script"
echo "Installing all development tools..."
echo -e "========================================${NC}"
echo ""

# Phase 1: System Tools
echo -e "${YELLOW}========================================"
echo "Phase 1: System Development Tools"
echo -e "========================================${NC}"
echo ""
echo -e "${BLUE}Installing build-essential, gdb, python3-venv, python-is-python3, git, iproute2...${NC}"
"$SCRIPT_DIR/install-tools.sh"

# Phase 2: tmux and vim
echo ""
echo -e "${YELLOW}========================================"
echo "Phase 2: Terminal Multiplexer & Editor"
echo -e "========================================${NC}"
echo ""
echo -e "${BLUE}[1/2] Installing and configuring tmux...${NC}"
"$SCRIPT_DIR/install-tmux.sh"

echo ""
echo -e "${BLUE}[2/2] Installing and configuring vim...${NC}"
"$SCRIPT_DIR/install-vim.sh"

# Phase 3: Docker
echo ""
echo -e "${YELLOW}========================================"
echo "Phase 3: Container Platform"
echo -e "========================================${NC}"
echo ""
echo -e "${BLUE}Installing docker...${NC}"
"$SCRIPT_DIR/install-docker.sh"

# Phase 4: Tailscale
echo ""
echo -e "${YELLOW}========================================"
echo "Phase 4: VPN & Networking"
echo -e "========================================${NC}"
echo ""
echo -e "${BLUE}Installing tailscale...${NC}"
"$SCRIPT_DIR/install-tailscale.sh"

# Phase 5: Shell & Fonts
echo ""
echo -e "${YELLOW}========================================"
echo "Phase 5: Shell Prompt & Fonts"
echo -e "========================================${NC}"
echo ""
echo -e "${BLUE}[1/2] Installing starship prompt...${NC}"
"$SCRIPT_DIR/install-starship.sh"

echo ""
echo -e "${BLUE}[2/2] Installing nerd fonts...${NC}"
"$SCRIPT_DIR/install-nerdfonts.sh"

# Final summary
echo ""
echo -e "${GREEN}========================================"
echo "🎉 SETUP COMPLETE! 🎉"
echo -e "========================================${NC}"
echo ""
echo "Installed and configured:"
echo "  ✓ System tools (build-essential, gdb, python3, git, ip)"
echo "  ✓ tmux with configuration"
echo "  ✓ vim with plugins (Vundle, themes, NERDTree, vim-airline)"
echo "  ✓ docker"
echo "  ✓ tailscale VPN"
echo "  ✓ starship prompt"
echo "  ✓ FiraMono Nerd Font"
echo ""
echo "Next steps:"
echo "  1. Close and reopen your terminal (or run: source ~/.bashrc)"
echo "  2. Configure your terminal to use 'FiraMono Nerd Font'"
echo "  3. Start tmux and install plugins with: Ctrl+a then Shift+i"
echo "  4. Connect to tailscale: sudo tailscale up"
echo "  5. Add yourself to docker group (Ubuntu): sudo usermod -aG docker \$USER && newgrp docker"
echo ""
echo "To clean up:"
echo "  $0 --clean      # Stop services and remove configs"
echo "  $0 --clean-all  # Completely uninstall everything"
echo ""
echo "Enjoy your development environment! 🚀"
