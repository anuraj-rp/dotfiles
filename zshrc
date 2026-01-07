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

# FZF configuration
export FZF_DEFAULT_OPTS='
  --color=fg:#ebdbb2,bg:#282828,hl:#fabd2f
  --color=fg+:#ebdbb2,bg+:#3c3836,hl+:#fabd2f
  --color=info:#83a598,prompt:#bdae93,pointer:#fb4934
  --color=marker:#fe8019,spinner:#b8bb26,header:#83a598
  --height=40%
  --layout=reverse
  --border
  --ansi
'

# Use ls with colors for file listing (Ctrl+T)
export FZF_CTRL_T_OPTS="--preview 'ls -la --color=always {}' --preview-window=right:40%"

# Use ls with colors for directory listing (Alt+C)
export FZF_ALT_C_OPTS="--preview 'ls -la --color=always {}' --preview-window=right:40%"

# FZF finder commands - uses fd/rg if available, falls back to find
# Set FZF_FINDER=find to force using find instead of fd
if [[ -z "$FZF_FINDER" ]]; then
    if command -v fd &>/dev/null; then
        FZF_FINDER="fd"
    elif command -v fdfind &>/dev/null; then
        FZF_FINDER="fdfind"
    else
        FZF_FINDER="find"
    fi
fi

if [[ "$FZF_FINDER" == "fd" || "$FZF_FINDER" == "fdfind" ]]; then
    # fd: fast, colored, respects .gitignore
    export FZF_CTRL_T_COMMAND="$FZF_FINDER --color=always --hidden --exclude .git"
    export FZF_ALT_C_COMMAND="$FZF_FINDER --type d --color=always --hidden --exclude .git"
else
    # find: fallback with manual ignore list
    export FZF_CTRL_T_COMMAND='find . \( -name .git -o -name node_modules -o -name __pycache__ -o -name .venv -o -name .cache -o -name build -o -name dist -o -name .next -o -name target -o -name vendor \) -prune -o \( -type f -o -type d \) -print 2>/dev/null | sed "s|^\./||"'
    export FZF_ALT_C_COMMAND='find . \( -name .git -o -name node_modules -o -name __pycache__ -o -name .venv -o -name .cache -o -name build -o -name dist -o -name .next -o -name target -o -name vendor \) -prune -o -type d -print 2>/dev/null | sed "s|^\./||"'
fi

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

# Interactive ripgrep search with fzf (usage: rgi "pattern")
rgi() {
    rg --color=always --line-number --no-heading "$@" |
        fzf --ansi \
            --delimiter ':' \
            --preview 'bat --color=always --highlight-line {2} {1} 2>/dev/null || head -100 {1}' \
            --preview-window 'right:60%:+{2}-10' \
            --bind 'enter:become(vim {1} +{2})'
}
