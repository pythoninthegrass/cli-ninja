# fd - File Finding Patterns

## Overview

`fd` is a fast, user-friendly alternative to `find`. It respects `.gitignore` by default and uses intuitive patterns.

## Basic Usage

```bash
# Find files/directories by name (case-insensitive by default)
fd pattern

# Case-sensitive search
fd -s Pattern

# Case-insensitive explicitly
fd -i pattern
```

## File Type Filtering

```bash
# By extension
fd -e py           # All .py files
fd -e js -e ts     # Multiple extensions

# By type
fd -t f            # Files only
fd -t d            # Directories only
fd -t l            # Symlinks only
fd -t x            # Executable files only

# Combine type and extension
fd -t f -e py      # Python files only
```

## Search Scope

```bash
# Search in specific directory
fd pattern /path/to/dir

# Multiple directories
fd pattern dir1/ dir2/

# Depth control
fd -d 1 pattern    # Current directory only
fd -d 3 pattern    # Up to 3 levels deep
fd --max-depth 2   # Alternative syntax
```

## Advanced Filtering

### By Size

```bash
# Files larger than 100MB
fd -t f --size +100m

# Files smaller than 1KB
fd -t f --size -1k

# Files between 10KB and 1MB
fd -t f --size +10k --size -1m
```

### By Time

```bash
# Modified in last 7 days
fd --changed-within 7d

# Modified more than 30 days ago
fd --changed-before 30d

# Specific date ranges
fd --changed-within 2024-01-01..2024-12-31
```

### Hidden and Ignored Files

```bash
# Include hidden files
fd -H pattern

# Ignore .gitignore rules
fd -u pattern

# Both hidden and ignored
fd -Hu pattern

# Search in .git directories
fd -H -u -I pattern
```

## Exclusion Patterns

```bash
# Exclude specific patterns
fd -E '*.pyc' -E '__pycache__' pattern

# Exclude directories
fd -E 'node_modules' -E '.git' pattern

# Multiple exclusions
fd -e py -E '*test*' -E '*_pb2.py'
```

## Output Formatting

```bash
# Full paths
fd -a pattern

# Relative paths (default)
fd pattern

# Print absolute paths
fd -p pattern

# Null-separated output (for xargs -0)
fd -0 pattern
```

## Pattern Matching

```bash
# Exact name match
fd -g 'config.json'

# Wildcard patterns
fd -g '*.test.js'
fd -g 'test_*.py'

# Regex mode (default)
fd '^[A-Z].*\.py$'

# Fixed string (faster)
fd -F 'literal.string'
```

## Execution

```bash
# Execute command on each result
fd -e py -x python -m py_compile {}

# Execute with multiple files
fd -e txt -X cat

# Execute with placeholders
fd -e md -x echo "File: {}" "Path: {/}" "Dir: {//}"

# Parallel execution
fd -e py -x -j 4 pylint {}
```

## Common Workflows

### Find and Edit

```bash
# Find and edit config files
fd config | fzf | xargs $EDITOR

# Find recent Python files and edit
fd -e py --changed-within 1d | fzf | xargs $EDITOR
```

### Find and Delete

```bash
# Find and remove cache files
fd -e pyc -X rm
fd -t d __pycache__ -X rm -rf

# Interactive deletion
fd '*.log' -x rm -i {}
```

### Find and Copy

```bash
# Copy all Python files to backup
fd -e py -X cp -t backup/

# Copy with directory structure
fd -e py -x cp --parents {} backup/
```

### Statistics and Analysis

```bash
# Count files by type
fd -e py | wc -l

# List largest files
fd -t f --size +1m -x ls -lh {} | sort -k5 -hr

# Find duplicate filenames
fd | awk -F/ '{print $NF}' | sort | uniq -d
```

## Performance Tips

1. **Narrow scope early**: Use `-d` to limit depth, `-t` to filter type
2. **Use specific patterns**: More specific patterns are faster
3. **Respect .gitignore**: Default behavior is already optimized
4. **Use fixed strings**: `-F` is faster than regex when possible

## Common Use Cases

### Development

```bash
# Find test files
fd test -e py
fd -g '*_test.go'
fd -g '*.test.ts'

# Find configuration files
fd -e json -e yaml -e toml config

# Find source files excluding tests
fd -e py -E '*test*'

# Find files modified today
fd --changed-within 1d
```

### Documentation

```bash
# Find all markdown files
fd -e md

# Find README files
fd -i readme

# Find documentation directories
fd -t d docs
```

### Build Artifacts

```bash
# Find compiled files
fd -e o -e so -e dylib

# Find build directories
fd -t d -g 'build' -g 'dist' -g 'target'

# Find and clean
fd -e pyc -E '.venv' -X rm
```

## Comparison with find

| Task | find | fd |
|------|------|-----|
| Find by name | `find . -name '*.py'` | `fd -e py` |
| Files only | `find . -type f` | `fd -t f` |
| Max depth | `find . -maxdepth 2` | `fd -d 2` |
| Exclude pattern | `find . ! -path '*/test/*'` | `fd -E '*test*'` |
| Execute command | `find . -name '*.py' -exec python {} \;` | `fd -e py -x python {}` |

## Tips and Tricks

1. **Combine with other tools**:
   ```bash
   fd -e py | xargs wc -l        # Count lines
   fd -e md | xargs grip -b      # Preview markdown
   fd -0 | xargs -0 tar czf      # Create archive
   ```

2. **Use shell aliases**:
   ```bash
   alias fdd='fd -t d'           # Directories only
   alias fdf='fd -t f'           # Files only
   alias fdh='fd -H'             # Include hidden
   ```

3. **Create functions**:
   ```bash
   # Find and cd into directory
   fcd() { cd $(fd -t d "$1" | fzf) }

   # Find and open in editor
   fe() { $EDITOR $(fd "$1" | fzf) }
   ```
