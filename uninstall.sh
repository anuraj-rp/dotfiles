#!/bin/bash

# Complete Uninstaller
# Removes binaries and all configurations for selected tools

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Uninstall functions
uninstall_zsh() {
    echo ""
    echo -e "${BLUE}Uninstalling Zsh and related tools...${NC}"

    # Change default shell back to bash if currently zsh
    CURRENT_SHELL=$(getent passwd "$USER" | cut -d: -f7)
    if [[ "$CURRENT_SHELL" == *"zsh"* ]]; then
        info "Changing default shell back to bash..."
        chsh -s /bin/bash
    fi

    # Remove .zshrc
    [ -L "$HOME/.zshrc" ] && rm "$HOME/.zshrc" && info "Removed symlink: ~/.zshrc"
    [ -f "$HOME/.zshrc" ] && rm "$HOME/.zshrc" && info "Removed file: ~/.zshrc"

    # Remove zinit
    ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit"
    [ -d "$ZINIT_HOME" ] && rm -rf "$ZINIT_HOME" && info "Removed zinit: $ZINIT_HOME"

    # Remove zsh files
    [ -f "$HOME/.zsh_history" ] && rm "$HOME/.zsh_history" && info "Removed: ~/.zsh_history"
    rm -f "$HOME/.zcompdump"* 2>/dev/null

    # Uninstall binaries (zsh, fzf, curl, git)
    if command -v brew &>/dev/null; then
        brew uninstall zsh fzf 2>/dev/null || true
    elif command -v apt &>/dev/null; then
        sudo apt remove -y zsh fzf
        sudo apt autoremove -y
    fi

    info "Zsh and fzf uninstalled"
}

uninstall_tmux() {
    echo ""
    echo -e "${BLUE}Uninstalling Tmux...${NC}"

    # Remove config
    [ -L "$HOME/.tmux.conf" ] && rm "$HOME/.tmux.conf" && info "Removed symlink: ~/.tmux.conf"
    [ -f "$HOME/.tmux.conf" ] && rm "$HOME/.tmux.conf" && info "Removed file: ~/.tmux.conf"

    # Remove plugins (TPM)
    [ -d "$HOME/.tmux" ] && rm -rf "$HOME/.tmux" && info "Removed: ~/.tmux"

    # Uninstall binary
    if command -v brew &>/dev/null; then
        brew uninstall tmux 2>/dev/null || true
    elif command -v apt &>/dev/null; then
        sudo apt remove -y tmux && sudo apt autoremove -y
    fi

    info "Tmux uninstalled"
}

uninstall_vim() {
    echo ""
    echo -e "${BLUE}Uninstalling Vim...${NC}"

    # Remove config
    [ -L "$HOME/.vimrc" ] && rm "$HOME/.vimrc" && info "Removed symlink: ~/.vimrc"
    [ -f "$HOME/.vimrc" ] && rm "$HOME/.vimrc" && info "Removed file: ~/.vimrc"

    # Remove plugins (Vundle)
    [ -d "$HOME/.vim" ] && rm -rf "$HOME/.vim" && info "Removed: ~/.vim"

    # Uninstall binary
    if command -v brew &>/dev/null; then
        brew uninstall vim 2>/dev/null || true
    elif command -v apt &>/dev/null; then
        sudo apt remove -y vim && sudo apt autoremove -y
    fi

    info "Vim uninstalled"
}

uninstall_docker() {
    echo ""
    echo -e "${BLUE}Uninstalling Docker...${NC}"

    # Stop docker service
    if systemctl is-active --quiet docker 2>/dev/null; then
        sudo systemctl stop docker
        sudo systemctl disable docker
        info "Stopped and disabled docker service"
    fi

    # Uninstall
    if command -v brew &>/dev/null; then
        brew uninstall --cask docker 2>/dev/null || true
    elif command -v apt &>/dev/null; then
        sudo apt remove -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin 2>/dev/null || true
        sudo apt remove -y docker.io docker-doc docker-compose podman-docker 2>/dev/null || true
        sudo apt autoremove -y
    fi

    # Remove docker data (optional - ask user)
    if [ -d "/var/lib/docker" ]; then
        read -p "Remove all Docker data (images, containers, volumes)? (y/N) " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            sudo rm -rf /var/lib/docker
            sudo rm -rf /var/lib/containerd
            info "Removed Docker data"
        fi
    fi

    info "Docker uninstalled"
}

# Show menu
show_menu() {
    echo "========================================="
    echo "  Complete Uninstaller"
    echo "========================================="
    echo ""
    echo "Select tools to uninstall:"
    echo ""
    echo "  1) Zsh      (shell, zinit, fzf, plugins)"
    echo "  2) Tmux     (multiplexer, TPM, plugins)"
    echo "  3) Vim      (editor, Vundle, plugins)"
    echo "  4) Docker   (engine, CLI, data)"
    echo "  5) All of the above"
    echo ""
    echo "  0) Cancel"
    echo ""
}

# Main
main() {
    show_menu

    read -p "Enter choices (comma-separated, e.g., 1,2,3): " choices

    if [[ "$choices" == "0" ]]; then
        echo "Cancelled."
        exit 0
    fi

    # Parse choices
    UNINSTALL_ZSH=false
    UNINSTALL_TMUX=false
    UNINSTALL_VIM=false
    UNINSTALL_DOCKER=false

    IFS=',' read -ra SELECTIONS <<< "$choices"
    for sel in "${SELECTIONS[@]}"; do
        sel=$(echo "$sel" | tr -d ' ')
        case "$sel" in
            1) UNINSTALL_ZSH=true ;;
            2) UNINSTALL_TMUX=true ;;
            3) UNINSTALL_VIM=true ;;
            4) UNINSTALL_DOCKER=true ;;
            5) UNINSTALL_ZSH=true; UNINSTALL_TMUX=true; UNINSTALL_VIM=true; UNINSTALL_DOCKER=true ;;
            *) warn "Unknown option: $sel" ;;
        esac
    done

    # Confirm
    echo ""
    echo "Will uninstall:"
    $UNINSTALL_ZSH && echo "  - Zsh"
    $UNINSTALL_TMUX && echo "  - Tmux"
    $UNINSTALL_VIM && echo "  - Vim"
    $UNINSTALL_DOCKER && echo "  - Docker"
    echo ""

    read -p "Are you sure? (y/N) " -n 1 -r
    echo ""

    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Cancelled."
        exit 0
    fi

    # Execute uninstalls
    $UNINSTALL_ZSH && uninstall_zsh
    $UNINSTALL_TMUX && uninstall_tmux
    $UNINSTALL_VIM && uninstall_vim
    $UNINSTALL_DOCKER && uninstall_docker

    echo ""
    echo "========================================="
    echo -e "${GREEN}  Uninstallation Complete${NC}"
    echo "========================================="
    echo ""
    if $UNINSTALL_ZSH; then
        echo "Note: Log out and back in for shell change to take effect."
    fi
}

main "$@"
