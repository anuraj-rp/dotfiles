### 1. Initialize Zinit ###
# Sets up the plugin manager paths
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"

### 2. Prompt (Starship) ###
# Initialize Starship prompt (install via install-starship.sh)
eval "$(starship init zsh)"

### 3. Core Plugins ###
# Zsh-Completions (Additional completion definitions)
zinit light zsh-users/zsh-completions

# Initialize the completion system (ignore insecure directories)
autoload -Uz compinit && compinit -i
zinit cdreplay -q

# FZF-Tab (Replaces standard tab completion with FZF selection)
# MUST be loaded after compinit
zinit light Aloxaf/fzf-tab

# Configure FZF-Tab
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:*' fzf-command fzf
zstyle ':fzf-tab:*' single-group color
zstyle ':fzf-tab:*' show-group full

# FZF keybindings (Ctrl+R for history, Ctrl+T for files, Alt+C for cd)
if command -v fzf &>/dev/null; then
    if [[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ]]; then
        source /usr/share/doc/fzf/examples/key-bindings.zsh
    elif [[ -f /opt/homebrew/opt/fzf/shell/key-bindings.zsh ]]; then
        source /opt/homebrew/opt/fzf/shell/key-bindings.zsh
    fi
fi

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

# History Configuration
HISTSIZE=5000
SAVEHIST=5000
HISTFILE=~/.zsh_history
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE

### 6. Aliases ###
alias ls='ls --color=auto'
alias ll='ls -lah --color=auto'
alias la='ls -A --color=auto'
alias grep='grep --color=auto'
