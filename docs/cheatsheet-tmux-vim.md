# Quickstart Guide

## Tmux Commands

### Prefix Key
The prefix key is `Ctrl+a` (instead of default `Ctrl+b`).

| Action | Keys |
|--------|------|
| Send prefix to nested tmux | `Ctrl+a Ctrl+a` |

### Window Splitting

| Action | Keys |
|--------|------|
| Split horizontally | `Ctrl+a \|` |
| Split vertically | `Ctrl+a -` |

### Pane Resizing

| Action | Keys |
|--------|------|
| Resize pane down | `Ctrl+a j` |
| Resize pane up | `Ctrl+a k` |
| Resize pane right | `Ctrl+a l` |
| Resize pane left | `Ctrl+a h` |
| Toggle pane zoom (maximize/restore) | `Ctrl+a m` |

### Configuration

| Action | Keys |
|--------|------|
| Reload tmux config | `Ctrl+a r` |

### Navigation (vim-tmux-navigator)

| Action | Keys |
|--------|------|
| Move to pane below | `Ctrl+j` |
| Move to pane above | `Ctrl+k` |
| Move to pane right | `Ctrl+l` |
| Move to pane left | `Ctrl+h` |

### Other Features
- Mouse mode is enabled
- Vi mode keys enabled for copy mode
- Sessions persist across restarts (tmux-resurrect)

---

## Vim Commands

### Split Navigation

| Action | Keys |
|--------|------|
| Move to split below | `Ctrl+j` |
| Move to split above | `Ctrl+k` |
| Move to split right | `Ctrl+l` |
| Move to split left | `Ctrl+h` |

### Theme Toggle

| Action | Keys |
|--------|------|
| Toggle background (light/dark) | `F5` |

### NERDTree (File Explorer)

| Action | Keys |
|--------|------|
| Toggle NERDTree | `:NERDTreeToggle` |
| Open NERDTree | `:NERDTree` |
| Find current file | `:NERDTreeFind` |

### Git Integration (vim-fugitive)

| Action | Command |
|--------|---------|
| Git status | `:Git` or `:G` |
| Git diff | `:Gdiff` |
| Git blame | `:Gblame` |
| Git log | `:Glog` |
| Git commit | `:Gcommit` |

---

## Combined Workflows

### Seamless Navigation
Both Vim and Tmux use the same navigation keys (`Ctrl+h/j/k/l`) thanks to vim-tmux-navigator. This allows seamless movement between Vim splits and Tmux panes without switching mental context.

### Development Session Setup
```bash
# Start a new tmux session
tmux new -s dev

# Split the window for code + terminal
Ctrl+a |    # Split horizontally
Ctrl+a -    # Split vertically

# Navigate between panes
Ctrl+h/j/k/l

# Resize panes as needed
Ctrl+a h/j/k/l
```

### Quick Reference Card

| Context | Left | Down | Up | Right |
|---------|------|------|-----|-------|
| Navigate splits/panes | `Ctrl+h` | `Ctrl+j` | `Ctrl+k` | `Ctrl+l` |
| Resize panes (tmux) | `Prefix h` | `Prefix j` | `Prefix k` | `Prefix l` |

### Plugin Management

**Vim (Vundle):**
```vim
:PluginInstall    " Install plugins
:PluginUpdate     " Update plugins
:PluginClean      " Remove unused plugins
```

**Tmux (TPM):**
| Action | Keys |
|--------|------|
| Install plugins | `Ctrl+a I` |
| Update plugins | `Ctrl+a U` |
| Uninstall plugins | `Ctrl+a Alt+u` |
