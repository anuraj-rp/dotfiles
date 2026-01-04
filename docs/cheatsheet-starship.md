# Starship Cheatsheet

## Quick Commands

### Toggle Username Display
```bash
toggle_username
```
Toggles username visibility in the prompt. Reload shell after running.

### Reload Shell (Apply Changes)
```bash
source ~/.bashrc
```

### Check Starship Config
```bash
cat ~/.config/starship.toml
```

### Edit Starship Config
```bash
nano ~/.config/starship.toml
# or
vim ~/.config/starship.toml
```

## Setup Steps

### 1. Install Starship
```bash
./install-starship.sh
```

### 2. Configure Starship
```bash
./configure-starship.sh
```
This will:
- Install Gruvbox Rainbow preset
- Enable fish-style abbreviated paths (e.g., `~/s/g/dotfiles`)
- Disable username display (only OS icon shows)

### 3. Setup Bash Profile
```bash
./setup-bash.sh
```
Adds the `toggle_username` function to your bash profile.

### 4. Reload Shell
```bash
source ~/.bashrc
```

## Configuration Details

| Setting | Value | Description |
|---------|-------|-------------|
| Preset | Gruvbox Rainbow | Color scheme |
| truncation_length | 1 | Forces fish-style abbreviation |
| fish_style_pwd_dir_length | 1 | Shows first letter of each dir |
| truncate_to_repo | false | Don't truncate at repo root |
| username disabled | true | Hides username by default |

## File Locations

| File | Path |
|------|------|
| Starship Config | `~/.config/starship.toml` |
| Starship Binary | `~/.local/bin/starship` |
| Bash Profile | `~/.bash_profile` |

## Troubleshooting

### Starship Not Found
Ensure `~/.local/bin` is in your PATH:
```bash
export PATH="$HOME/.local/bin:$PATH"
```

### Changes Not Appearing
Reload your shell:
```bash
source ~/.bashrc
```

### Reset Configuration
Re-run the configuration script to reset to defaults:
```bash
./configure-starship.sh
```
