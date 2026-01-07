# Agents.md - Clean Zsh Setup Guide

This guide sets up a fast, modern **Zsh** environment on **Ubuntu 24.04** and **macOS**. It uses **Zinit** as the plugin manager (for performance) and includes **FZF**, **FZF-Tab**, **Autosuggestions**, and **Syntax Highlighting**, using the classic **RobbyRussell** theme.

## 1. Prerequisites

Before configuring Zsh, ensure the basic dependencies are installed.

### Ubuntu 24.04

```bash
sudo apt update
sudo apt install zsh git curl fzf

# Set Zsh as default shell
chsh -s $(which zsh)
```

### macOS

```bash
brew install zsh git fzf

# Set Zsh as default shell
chsh -s $(which zsh)
```

## 2. Install Zinit Plugin Manager

Run this command to install Zinit. It is significantly faster than standard Oh My Zsh but allows you to use all the same plugins.

```bash
bash -c "$(curl --fail --show-error --silent --location https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)"
```

## 3. Configuration (The .zshrc File)

Replace the entire contents of your `~/.zshrc` file with the configuration below.

```bash
### 1. Initialize Zinit ###
# Sets up the plugin manager paths
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"

### 2. Theme (RobbyRussell) ###
# Loads the default Oh-My-Zsh theme (Green arrow ➜)
zinit snippet OMZT::robbyrussell

### 3. Core Plugins ###
# Zsh-Completions (Additional completion definitions)
zinit light zsh-users/zsh-completions

# Initialize the completion system
autoload -Uz compinit && compinit

# FZF (Fuzzy Finder)
# Installs fzf binary and keybindings (Ctrl+T for files, Ctrl+R for history)
zinit pack"bgn-binary+keys" for fzf

# FZF-Tab (Replaces standard tab completion with FZF selection)
# MUST be loaded after compinit
zinit light Aloxaf/fzf-tab

# Configure FZF-Tab colors and preview
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# Preview directory contents when completing 'cd'
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'

### 4. Productivity Plugins ###
# Zsh-Autosuggestions (Suggests commands based on history as grey text)
zinit light zsh-users/zsh-autosuggestions

# Oh-My-Zsh Snippets (Useful aliases without installing full OMZ)
zinit snippet OMZP::git      # Git aliases (ga, gc, gst, gl)
zinit snippet OMZP::sudo     # Press Esc twice to add 'sudo' to the previous command
zinit snippet OMZP::cp       # 'cp' with a progress bar
zinit snippet OMZP::command-not-found

### 5. Syntax Highlighting ###
# MUST be the last plugin loaded to work correctly
zinit light zsh-users/zsh-syntax-highlighting

# Keybindings for Autosuggestions (Accept suggestion with Ctrl+Space)
bindkey '^ ' autosuggest-accept

# Optional: History Configuration
HISTSIZE=5000
SAVEHIST=5000
setopt SHARE_HISTORY
```

## 4. Post-Installation Steps

1. **Restart Zsh**: Close and reopen your terminal window, or run `exec zsh`.

2. **Verify Plugins**:
   - **Theme**: You should see the classic `➜ ~` prompt.
   - **Syntax Highlighting**: Type `echo "test"`. `echo` should turn green. Type `notacommand`. It should turn red.
   - **FZF History**: Press `Ctrl + R`. You should see a search window for your command history.
   - **FZF Tab**: Type `cd` followed by a space, then hit `Tab`. You should see an interactive list of folders.

## 5. Plugin Summary

| Plugin | Description |
|--------|-------------|
| `OMZT::robbyrussell` | The clean, default theme used by Oh My Zsh. |
| `FZF` | A general-purpose command-line fuzzy finder. |
| `FZF-Tab` | Replaces the old tab menu with the FZF interface. |
| `zsh-autosuggestions` | Suggests commands as you type based on history. |
| `zsh-syntax-highlighting` | Highlights commands in green (valid) or red (invalid). |
| `OMZP::sudo` | Quickly add sudo to a command by pressing Esc twice. |

# Youtube
  - https://www.youtube.com/watch?v=-iQpoqFL5ZY
  - https://www.youtube.com/watch?v=u-qLj4YBry0
  - https://www.youtube.com/watch?v=WXiNkZVmkD4
  - https://www.youtube.com/watch?v=80PHRWH84Tc
