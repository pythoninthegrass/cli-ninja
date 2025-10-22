# rg - Ripgrep Patterns and Usage

## Overview

`ripgrep` (rg) is an extremely fast text search tool that respects `.gitignore` and supports regex patterns.

## Basic Search

```bash
# Simple search
rg 'pattern'

# Case-insensitive
rg -i 'pattern'

# Case-sensitive (force)
rg -s 'Pattern'

# Smart case (case-insensitive unless uppercase present)
rg -S 'pattern'
```

## File Type Filtering

```bash
# Search in specific file types
rg -t py 'import'           # Python files
rg -t rust 'fn main'        # Rust files
rg -t js 'function'         # JavaScript files

# Multiple types
rg -t py -t js 'class'

# Exclude types
rg -T py 'pattern'          # Everything except Python

# List available types
rg --type-list
```

## Context Control

```bash
# Lines before match
rg -B 2 'pattern'

# Lines after match
rg -A 5 'pattern'

# Lines before and after
rg -C 3 'pattern'

# Both (different values)
rg -B 2 -A 5 'pattern'
```

## Output Formatting

```bash
# Show line numbers (default in terminal)
rg -n 'pattern'

# Hide line numbers
rg -N 'pattern'

# Show column numbers
rg --column 'pattern'

# Show file paths only
rg -l 'pattern'

# Show files without matches
rg --files-without-match 'pattern'

# Count matches per file
rg -c 'pattern'

# Count total matches
rg --count-matches 'pattern'
```

## Advanced Search

### Word Boundaries

```bash
# Match whole words only
rg -w 'word'

# Example: find 'test' but not 'testing'
rg -w 'test'

# Regex word boundaries
rg '\bword\b'
```

### Multiline Search

```bash
# Enable multiline mode
rg -U 'pattern.*spanning.*lines'

# Example: find function definitions
rg -U 'def \w+\([^)]*\):\s*"""[^"]*"""'

# Multiline with context
rg -U -C 2 'pattern.*multiline'
```

### Fixed Strings

```bash
# Literal string search (no regex, faster)
rg -F 'literal.string[with]special.chars'

# Case-insensitive literal
rg -F -i 'Literal String'
```

## File Filtering

### By Path

```bash
# Search in specific directory
rg 'pattern' src/

# Multiple directories
rg 'pattern' src/ tests/

# Glob patterns
rg -g '*.py' 'pattern'
rg -g '**/*test*.py' 'pattern'

# Multiple globs
rg -g '*.{js,ts}' 'pattern'

# Negative globs (exclude)
rg -g '!*test*' 'pattern'
rg -g '!*.min.js' 'pattern'
```

### Hidden and Ignored Files

```bash
# Search hidden files
rg --hidden 'pattern'

# Ignore .gitignore rules
rg --no-ignore 'pattern'

# Both
rg --hidden --no-ignore 'pattern'

# Search specific ignored directories
rg --no-ignore -g 'node_modules/**' 'pattern'
```

## Regex Patterns

### Basic Regex

```bash
# Any character
rg 'a.c'              # matches 'abc', 'a2c', etc.

# Character classes
rg '[0-9]+'           # one or more digits
rg '[a-zA-Z]+'        # letters only
rg '[^0-9]'           # anything except digits

# Anchors
rg '^pattern'         # start of line
rg 'pattern$'         # end of line
rg '^pattern$'        # entire line matches
```

### Quantifiers

```bash
# Zero or more
rg 'ab*c'             # ac, abc, abbc, etc.

# One or more
rg 'ab+c'             # abc, abbc, etc.

# Zero or one
rg 'ab?c'             # ac, abc

# Exact count
rg 'a{3}'             # aaa
rg 'a{2,4}'           # aa, aaa, aaaa
rg 'a{2,}'            # aa, aaa, aaaa, etc.
```

### Groups and Alternation

```bash
# Groups
rg '(ab)+'            # ab, abab, ababab, etc.

# Alternation
rg 'cat|dog'          # cat or dog
rg '(import|from) numpy'

# Non-capturing groups
rg '(?:http|https)://[^\s]+'
```

### Lookahead/Lookbehind

```bash
# Positive lookahead
rg 'test(?=_unit)'    # 'test' followed by '_unit'

# Negative lookahead
rg 'test(?!_integration)'  # 'test' not followed by '_integration'

# Positive lookbehind
rg '(?<=def )\\w+'    # word after 'def '

# Negative lookbehind
rg '(?<!@)property'   # 'property' not preceded by '@'
```

## Replacement (with sed/perl)

```bash
# Find and replace (dry run)
rg -l 'old_pattern' | xargs sed -n 's/old_pattern/new_pattern/gp'

# Find and replace (in-place)
rg -l 'old_pattern' | xargs sed -i '' 's/old_pattern/new_pattern/g'

# Using perl for complex replacements
rg -l 'pattern' | xargs perl -pi -e 's/old/new/g'
```

## JSON Output

```bash
# JSON output for scripting
rg --json 'pattern'

# Parse with jq
rg --json 'pattern' | jq -r 'select(.type == "match") | .data.path.text'

# Get line numbers
rg --json 'pattern' | jq -r 'select(.type == "match") | "\(.data.path.text):\(.data.line_number)"'
```

## Statistics and Analysis

```bash
# Show statistics
rg --stats 'pattern'

# Count matches per file
rg -c 'pattern' | sort -t: -k2 -nr

# Find most common matches
rg -o 'pattern' | sort | uniq -c | sort -nr

# Files with most matches
rg -c 'TODO' | awk -F: '$2 > 0' | sort -t: -k2 -nr | head
```

## Common Workflows

### Code Search

```bash
# Find function definitions (Python)
rg 'def \w+\(' -t py

# Find class definitions
rg 'class \w+' -t py

# Find imports
rg 'from .* import' -t py

# Find TODO/FIXME comments
rg '(TODO|FIXME|XXX|HACK):'

# Find console.log statements
rg 'console\.(log|error|warn)' -t js
```

### Configuration Search

```bash
# Find API keys (be careful!)
rg -i 'api[_-]?key' -g '!*.md'

# Find environment variables
rg 'process\.env\.' -t js
rg 'os\.getenv' -t py

# Find hardcoded IPs
rg '\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b'

# Find URLs
rg 'https?://[^\s<>"{}|\\^`\[\]]+'
```

### Dependency Analysis

```bash
# Find all imports of a module
rg 'from mymodule import' -t py

# Find all requires
rg "require\(['\"].*['\"]\\)" -t js

# Find external dependencies
rg 'import.*from ["\'](?!\.)[^"\']+' -t py
```

### Testing

```bash
# Find test functions
rg 'def test_\w+' -t py
rg 'it\(["\']' -t js

# Find assertions
rg 'assert\w*\(' -t py
rg 'expect\(' -t js

# Find skipped tests
rg '@skip|@pytest\.mark\.skip' -t py
rg '\.skip\(' -t js
```

## Performance Tips

1. **Use file type filters**: `-t` is faster than glob patterns
2. **Use fixed strings when possible**: `-F` bypasses regex engine
3. **Limit search scope**: Specify directories explicitly
4. **Use word boundaries**: `-w` is faster than `\b` regex
5. **Respect .gitignore**: Default behavior is already optimized

## Interactive Workflows

```bash
# Search and edit
rg -l 'TODO' | fzf | xargs $EDITOR

# Search with preview
rg --line-number 'pattern' | fzf --delimiter : --preview 'bat --color=always {1} --highlight-line {2}'

# Multi-select and edit
rg -l 'pattern' | fzf -m | xargs $EDITOR

# Search, select, and replace
FILE=$(rg -l 'pattern' | fzf)
rg 'pattern' "$FILE" | fzf
```

## Configuration

Create `~/.ripgreprc` for default options:

```bash
# Always show line numbers
--line-number

# Smart case search
--smart-case

# Follow symlinks
--follow

# Custom type definitions
--type-add=web:*.{html,css,js}*
```

Use with: `export RIPGREP_CONFIG_PATH=~/.ripgreprc`

## Comparison with grep

| Task | grep | rg |
|------|------|-----|
| Case-insensitive | `grep -i` | `rg -i` |
| Recursive | `grep -r` | `rg` (default) |
| Show line numbers | `grep -n` | `rg -n` (default) |
| Context | `grep -C 3` | `rg -C 3` |
| File type | `grep --include='*.py'` | `rg -t py` |
| Exclude pattern | `grep --exclude='test*'` | `rg -g '!test*'` |

## Tips and Tricks

### Shell Aliases

```bash
alias rgi='rg -i'                    # Case-insensitive
alias rga='rg --hidden --no-ignore'  # Search everything
alias rgl='rg -l'                    # Files only
alias rgc='rg -c'                    # Count per file
```

### Functions

```bash
# Search and edit function
rge() {
  rg -l "$1" | fzf --preview "rg --color=always -C 5 '$1' {}" | xargs $EDITOR
}

# Search in specific file type
rgt() {
  TYPE=$1
  shift
  rg -t "$TYPE" "$@"
}

# Search with context and open
rgf() {
  rg --line-number "$1" | fzf --delimiter : --preview 'bat --color=always {1} --highlight-line {2}' | awk -F: '{print $1}' | xargs $EDITOR
}
```

### Complex Patterns

```bash
# Email addresses
rg '\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b'

# Phone numbers (US)
rg '\b\d{3}[-.]?\d{3}[-.]?\d{4}\b'

# Hex colors
rg '#[0-9a-fA-F]{6}\b'

# Semantic versions
rg '\b\d+\.\d+\.\d+\b'

# Python function with type hints
rg 'def \w+\([^)]*\) -> \w+:'

# SQL queries in code
rg -U 'SELECT.*FROM.*WHERE'
```
