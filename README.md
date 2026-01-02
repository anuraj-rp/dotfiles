# dotfiles

Development environment setup scripts for Ubuntu and macOS.

## Quick Start

Run the master setup script to install everything:

```bash
./setup-machine.sh
```

## User Management

### Add a New User

```bash
# Create user with home directory and bash shell
sudo useradd -m -s /bin/bash username

# Set password
sudo passwd username

# Add to sudo group (optional)
sudo usermod -aG sudo username
```

### Add User to Groups

```bash
# Add user to a single group
sudo usermod -aG groupname username

# Add user to multiple groups
sudo usermod -aG group1,group2,group3 username

# Common groups
sudo usermod -aG sudo username      # Grant sudo privileges
sudo usermod -aG docker username    # Allow docker without sudo
```

### Verify Group Membership

```bash
# Check user's groups
groups username

# View detailed user info
id username
```

## Installed Tools

- System tools (build-essential, gdb, python3, git, zip/unzip, fontconfig)
- tmux with custom configuration
- vim with plugins (Vundle, themes, NERDTree, vim-airline)
- Docker
- Tailscale VPN
- Starship prompt
- FiraMono Nerd Font

## Individual Scripts

```bash
./install-tools.sh       # System development tools
./install-tmux.sh        # tmux with configuration
./install-vim.sh         # vim with plugins
./install-docker.sh      # Docker Engine
./install-tailscale.sh   # Tailscale VPN
./install-nerdfonts.sh   # FiraMono Nerd Font
./install-starship.sh    # Starship prompt
```

## Cleanup

```bash
./setup-machine.sh --clean      # Stop services and remove configs
./setup-machine.sh --clean-all  # Completely uninstall everything
```
