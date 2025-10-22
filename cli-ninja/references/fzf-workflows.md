# fzf - Interactive Selection Workflows

## Overview

`fzf` is a command-line fuzzy finder that enables interactive selection from lists. It's a powerful tool for building interactive workflows.

## Basic Usage

```bash
# Pipe any list to fzf
ls | fzf

# Multi-select with Tab
ls | fzf -m

# Use selected result
SELECTED=$(ls | fzf)
echo "You selected: $SELECTED"
```

## Preview Windows

### Basic Preview

```bash
# Preview with cat
fd | fzf --preview 'cat {}'

# Preview with bat (syntax highlighting)
fd | fzf --preview 'bat --color=always {}'

# Preview with line numbers
fd | fzf --preview 'bat --color=always --line-range :500 {}'
```

### Preview Window Configuration

```bash
# Position and size
fzf --preview 'cat {}' --preview-window=right:50%
fzf --preview 'cat {}' --preview-window=up:40%
fzf --preview 'cat {}' --preview-window=down:30%
fzf --preview 'cat {}' --preview-window=left:50%

# Hidden by default (toggle with ctrl-/)
fzf --preview 'cat {}' --preview-window=hidden

# Wrap text
fzf --preview 'cat {}' --preview-window=wrap

# No wrap (default)
fzf --preview 'cat {}' --preview-window=nowrap
```

### Advanced Previews

```bash
# Preview with highlighted search term
rg --line-number 'pattern' | \
  fzf --delimiter : \
      --preview 'bat --color=always {1} --highlight-line {2}'

# Preview JSON with jq
fd -e json | fzf --preview 'jq --color-output . {}'

# Preview images (requires chafa/imgcat)
fd -e png -e jpg | fzf --preview 'chafa {}'

# Preview directories
fd -t d | fzf --preview 'ls -la {}'

# Preview with tree
fd -t d | fzf --preview 'tree -L 2 {}'

# Multi-level preview (file type detection)
fd | fzf --preview '[[ -f {} ]] && bat --color=always {} || tree -L 1 {}'
```

## Keybindings

### Default Keybindings

```
ctrl-j / ctrl-n / down    : Move down
ctrl-k / ctrl-p / up      : Move up
enter                     : Select and exit
tab                       : Mark item (multi-select)
shift-tab                 : Unmark item
ctrl-c / esc              : Exit without selection
ctrl-/                    : Toggle preview window
```

### Custom Keybindings

```bash
# Copy to clipboard (macOS)
fzf --bind 'ctrl-y:execute-silent(echo {} | pbcopy)'

# Copy to clipboard (Linux)
fzf --bind 'ctrl-y:execute-silent(echo {} | xclip -selection clipboard)'

# Open in editor
fzf --bind 'ctrl-e:execute($EDITOR {})'

# Open in editor and exit
fzf --bind 'ctrl-e:execute($EDITOR {})+abort'

# Delete file with confirmation
fzf --bind 'ctrl-d:execute(rm -i {})'

# Multiple bindings
fzf --bind 'ctrl-e:execute($EDITOR {})' \
    --bind 'ctrl-y:execute-silent(echo {} | pbcopy)' \
    --bind 'ctrl-d:execute(rm -i {})'
```

### Advanced Keybinding Actions

```bash
# Reload results
fzf --bind 'ctrl-r:reload(fd)'

# Change preview
fzf --preview 'bat {}' \
    --bind 'ctrl-/:change-preview-window(hidden|)'

# Toggle between preview styles
fzf --preview 'bat --color=always {}' \
    --bind 'ctrl-t:change-preview(tree -L 2 {})'

# Accept and execute
fzf --bind 'enter:execute(echo Selected: {})+accept'
```

## Search Syntax

### Fuzzy Matching

```
# Basic fuzzy search
abc       # Matches files containing 'a', 'b', 'c' in order
          # Examples: abc, aXXbXXc, axbxc

# Exact match (single quote)
'abc      # Matches files containing exact string "abc"

# Prefix match (caret)
^abc      # Matches files starting with "abc"

# Suffix match (dollar)
abc$      # Matches files ending with "abc"

# Exact match (both)
^abc$     # Matches exactly "abc"
```

### Logical Operators

```
# AND (space)
abc def   # Contains both "abc" AND "def"

# OR (pipe)
abc|def   # Contains "abc" OR "def"

# NOT (exclamation)
abc !def  # Contains "abc" but NOT "def"

# Combination
abc def|ghi !jkl
# Contains "abc" AND ("def" OR "ghi") but NOT "jkl"
```

### Field Selection

```bash
# Search specific field (delimiter-separated)
# -d : Set delimiter
# -n : Select field number (1-indexed)
# --with-nth : Display specific fields

# Example: search only filenames in paths
fd | fzf -d / --with-nth -1

# Example: search only line numbers
rg --line-number 'pattern' | fzf -d : --with-nth 2
```

## Common Workflows

### File Navigation

```bash
# Find and edit file
fe() {
  local file
  file=$(fd --type f | fzf --preview 'bat --color=always {}')
  [[ -n "$file" ]] && $EDITOR "$file"
}

# Find and cd to directory
fcd() {
  local dir
  dir=$(fd --type d | fzf --preview 'tree -L 1 {}')
  [[ -n "$dir" ]] && cd "$dir"
}

# Find file with content preview
ff() {
  local file
  file=$(rg --files-with-matches "${1:-.}" | \
    fzf --preview "rg --color=always --context 5 '$1' {}")
  [[ -n "$file" ]] && $EDITOR "$file"
}
```

### Code Search

```bash
# Search content and edit
fzf_grep() {
  local line
  line=$(rg --line-number "$1" | \
    fzf --delimiter : \
        --preview 'bat --color=always {1} --highlight-line {2}' \
        --preview-window +{2}-/2)

  if [[ -n "$line" ]]; then
    local file=$(echo "$line" | cut -d: -f1)
    local lineno=$(echo "$line" | cut -d: -f2)
    $EDITOR "+$lineno" "$file"
  fi
}

# Find function definition and edit
find_function() {
  local result
  result=$(ast-grep --pattern "def $1(\$\$\$):" | \
    fzf --preview 'bat --color=always {1}')

  if [[ -n "$result" ]]; then
    local file=$(echo "$result" | cut -d: -f1)
    $EDITOR "$file"
  fi
}
```

### Git Integration

```bash
# Interactive git add
fga() {
  git status --short | \
    fzf -m --preview 'git diff --color=always {2}' | \
    awk '{print $2}' | \
    xargs git add
}

# Interactive git checkout
fgco() {
  git branch --all | \
    grep -v HEAD | \
    sed 's/^[* ]*//' | \
    sed 's#remotes/origin/##' | \
    sort -u | \
    fzf --preview 'git log --oneline --color=always {}' | \
    xargs git checkout
}

# Interactive git log
fgl() {
  git log --oneline --color=always | \
    fzf --ansi --preview 'git show --color=always {1}' | \
    awk '{print $1}' | \
    xargs git show
}

# Interactive git diff
fgd() {
  git diff --name-only | \
    fzf --preview 'git diff --color=always {}' | \
    xargs git diff
}
```

### Process Management

```bash
# Interactive kill
fkill() {
  local pid
  pid=$(ps aux | \
    sed 1d | \
    fzf -m --header='Select process to kill' | \
    awk '{print $2}')

  if [[ -n "$pid" ]]; then
    echo "$pid" | xargs kill -${1:-9}
  fi
}

# Interactive lsof (find what's using a port)
fport() {
  local port
  port=$(lsof -i -P -n | \
    sed 1d | \
    fzf --header='Select connection' | \
    awk '{print $2}')

  [[ -n "$port" ]] && echo "PID: $port"
}
```

### Docker Integration

```bash
# Interactive container selection
fdocker() {
  docker ps -a | \
    sed 1d | \
    fzf --header='Select container' | \
    awk '{print $1}'
}

# Interactive container logs
fdlogs() {
  local container
  container=$(fdocker)
  [[ -n "$container" ]] && docker logs -f "$container"
}

# Interactive container exec
fdexec() {
  local container
  container=$(fdocker)
  [[ -n "$container" ]] && docker exec -it "$container" /bin/bash
}
```

### Package Management

```bash
# Interactive npm script runner
fnpm() {
  local script
  script=$(cat package.json | \
    jq -r '.scripts | keys[]' | \
    fzf --preview 'jq -r ".scripts.{}" package.json')

  [[ -n "$script" ]] && npm run "$script"
}

# Interactive pip package info
fpip() {
  pip list | \
    fzf --preview 'pip show {1}'
}
```

### Configuration Files

```bash
# Edit config file
fconf() {
  local file
  file=$(fd -H -t f \
    -e conf -e config -e json -e yaml -e yml -e toml -e ini \
    . "$HOME/.config" | \
    fzf --preview 'bat --color=always {}')

  [[ -n "$file" ]] && $EDITOR "$file"
}

# Edit dotfile
fdot() {
  local file
  file=$(fd -H -t f '^\..*' "$HOME" --max-depth 1 | \
    fzf --preview 'bat --color=always {}')

  [[ -n "$file" ]] && $EDITOR "$file"
}
```

## Advanced Configurations

### Color Schemes

```bash
# Monokai
export FZF_DEFAULT_OPTS='
  --color=fg:#f8f8f2,bg:#272822,hl:#66d9ef
  --color=fg+:#f8f8f2,bg+:#44475a,hl+:#66d9ef
  --color=info:#a6e22e,prompt:#f92672,pointer:#f92672
  --color=marker:#f92672,spinner:#a6e22e,header:#6272a4
'

# Nord
export FZF_DEFAULT_OPTS='
  --color=fg:#e5e9f0,bg:#3b4252,hl:#81a1c1
  --color=fg+:#e5e9f0,bg+:#434c5e,hl+:#81a1c1
  --color=info:#eacb8a,prompt:#bf616a,pointer:#b48ead
  --color=marker:#a3be8b,spinner:#b48ead,header:#a3be8b
'

# Tokyo Night
export FZF_DEFAULT_OPTS='
  --color=fg:#c0caf5,bg:#1a1b26,hl:#bb9af7
  --color=fg+:#c0caf5,bg+:#292e42,hl+:#7dcfff
  --color=info:#7aa2f7,prompt:#7dcfff,pointer:#7dcfff
  --color=marker:#9ece6a,spinner:#9ece6a,header:#9ece6a
'
```

### Layout Options

```bash
# Reverse layout (prompt at top)
fzf --reverse

# Full screen
fzf --height=100%

# 40% of screen
fzf --height=40%

# Border
fzf --border
fzf --border=rounded
fzf --border=sharp

# Inline info
fzf --inline-info

# No info
fzf --no-info
```

### Performance Options

```bash
# Limit results
fzf --select-1      # Auto-select if only one match
fzf --exit-0        # Exit if no match

# Algorithm
fzf --algo=v1       # Faster, less accurate
fzf --algo=v2       # Default, balanced

# History
fzf --history=/tmp/fzf-history
```

## Environment Variables

```bash
# Default command
export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'

# Default options
export FZF_DEFAULT_OPTS='
  --height 40%
  --layout=reverse
  --border
  --inline-info
  --preview "bat --color=always --line-range :500 {}"
  --bind ctrl-/:toggle-preview
'

# ctrl-t command (file widget)
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_CTRL_T_OPTS="
  --preview 'bat --color=always --line-range :500 {}'
  --bind 'ctrl-/:toggle-preview'
"

# alt-c command (directory widget)
export FZF_ALT_C_COMMAND='fd --type d --hidden --exclude .git'
export FZF_ALT_C_OPTS="
  --preview 'tree -L 1 {}'
"
```

## Shell Integration

### Bash/Zsh Key Bindings

```bash
# Add to ~/.bashrc or ~/.zshrc
source /usr/share/doc/fzf/examples/key-bindings.bash  # Bash
source /usr/share/doc/fzf/examples/key-bindings.zsh   # Zsh

# Or via package manager
eval "$(fzf --bash)"  # Bash
eval "$(fzf --zsh)"   # Zsh
```

Default bindings:

- `ctrl-t`: Paste selected files
- `ctrl-r`: Paste from command history
- `alt-c`: cd into selected directory

### Custom Shell Functions

```bash
# Add to ~/.bashrc or ~/.zshrc

# fh - repeat history
fh() {
  print -z $( ([ -n "$ZSH_NAME" ] && fc -l 1 || history) | \
    fzf +s --tac | \
    sed -E 's/ *[0-9]*\*? *//' | \
    sed -E 's/\\/\\\\/g')
}

# fbr - checkout git branch
fbr() {
  local branches branch
  branches=$(git branch -vv) &&
  branch=$(echo "$branches" | fzf +m) &&
  git checkout $(echo "$branch" | awk '{print $1}' | sed "s/.* //")
}

# fshow - git commit browser
fshow() {
  git log --graph --color=always \
      --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" |
  fzf --ansi --no-sort --reverse --tiebreak=index --bind=ctrl-s:toggle-sort \
      --bind "ctrl-m:execute:
                (grep -o '[a-f0-9]\{7\}' | head -1 |
                xargs -I % sh -c 'git show --color=always % | less -R') << 'FZF-EOF'
                {}
FZF-EOF"
}
```

## Tips and Tricks

### Performance

1. Use fd instead of find for FZF_DEFAULT_COMMAND
2. Limit preview size with --line-range
3. Use --select-1 and --exit-0 for automation
4. Cache results for repeated searches

### User Experience

1. Always provide preview when possible
2. Use semantic keybindings (ctrl-e for edit)
3. Provide helpful --header messages
4. Use --multi for batch operations
5. Toggle preview with ctrl-/ for large files

### Integration

```bash
# Combine with xargs
fd -e py | fzf -m | xargs wc -l

# Combine with while read
fd | fzf -m | while read file; do
  echo "Processing: $file"
  # Process file
done

# Combine with command substitution
vim $(fzf)
cd $(fd -t d | fzf)
```

### Scripting

```bash
# Exit code check
if result=$(fd | fzf); then
  echo "Selected: $result"
else
  echo "No selection or cancelled"
  exit 1
fi

# Multi-select results
selected=$(fd | fzf -m)
if [[ -n "$selected" ]]; then
  echo "$selected" | while read file; do
    process "$file"
  done
fi
```
