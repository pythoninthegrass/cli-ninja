# CLI Ninja Skill

> ```
> ## Tooling for shell interactions 
> Is it about finding FILES? use 'fd' 
> Is it about finding TEXT/strings? use 'rg' 
> Is it about finding CODE STRUCTURE? use 'ast-grep'
> Is it about SELECTING from multiple results? pipe to 'fzf' 
> Is it about interacting with JSON? use 'jq' 
> Is it about interacting with YAML or XML? use 'yq'
> ```

-- [Acceptable-Garage906](https://www.reddit.com/r/ClaudeAI/comments/1lefmff/comment/mykm3nz/)

A [Claude skill](https://support.claude.com/en/articles/12512176-what-are-skills) for mastering CLI navigation and code exploration using modern command-line tools.

## Overview

The `cli-ninja` skill provides guidance for efficient repository navigation and code exploration using these tools:

- **fd** - Fast file finding
- **rg** (ripgrep) - Lightning-fast text search
- **ast-grep** - Code structure search by AST
- **fzf** - Interactive fuzzy selection
- **jq** - JSON processing
- **yq** - YAML/XML processing

## What's Included

### SKILL.md (12.4 KB)

Main skill file with:

- Tool selection decision tree
- Quick reference guide for all 6 tools
- Combination workflows (7 common patterns)
- Best practices and performance tips
- Integration examples

### References (63 KB total)

Comprehensive guides for each tool:

- `fd-patterns.md` (5.1 KB) - File finding patterns and flags
- `rg-patterns.md` (8.2 KB) - Text search patterns and regex tips
- `ast-grep-guide.md` (14 KB) - Code structure patterns for Python, Zig, Go, Ruby, JS/TS, Rust
- `fzf-workflows.md` (12 KB) - Interactive selection and preview configurations
- `jq-cookbook.md` (11.4 KB) - JSON transformations and filters
- `yq-examples.md` (12.4 KB) - YAML/XML processing examples

### Scripts (18.9 KB total)

Reusable workflow examples:

- `combo-search.sh` (8.2 KB) - 10 common combination workflows
- `interactive-code-finder.sh` (10.8 KB) - Interactive ast-grep + fzf tool

## Tool Selection Decision Tree

```
What are you looking for?

├─ FILES by name/path/extension?
│  └─ Use: fd
│     └─ Need to select from results? → Pipe to fzf
│
├─ TEXT/STRINGS in file contents?
│  └─ Use: rg (ripgrep)
│     └─ Need to select from results? → Pipe to fzf
│
├─ CODE STRUCTURE (functions, classes, imports)?
│  └─ Use: ast-grep
│     └─ Need to select from results? → Pipe to fzf
│     └─ Need to refactor/replace? → Use ast-grep --rewrite
│
├─ Working with JSON data?
│  └─ Use: jq
│
└─ Working with YAML or XML data?
   └─ Use: yq
```

## Example Workflows

### 1. Find and Edit Files with Context

```bash
rg -l 'def process_data' -t py | fzf --preview 'rg -C 5 "def process_data" {}' | xargs $EDITOR
```

### 2. Code Refactoring

```bash
ast-grep --pattern 'old_function($$$)' --rewrite 'new_function($$$)' -l py --interactive
```

### 3. Interactive Configuration Explorer

```bash
fd -e json | fzf --preview 'jq . {}'
```

## Key Features

- **Language-agnostic**: Patterns for Python, JavaScript/TypeScript, Rust, Go, Zig, and Ruby
- **Practical examples**: Real-world workflows for common tasks
- **Performance tips**: Optimize searches for speed
- **Integration ready**: Combine tools for powerful workflows
- **Interactive scripts**: Ready-to-use bash scripts for complex searches

## Installation

1. Download `cli-ninja.zip`
2. Install in Claude Code (instructions vary by platform)
3. Invoke the skill when navigating repositories or searching code

## When to Use This Skill

Use the cli-ninja skill when:

- Navigating repositories and codebases
- Searching for files, text, or code patterns
- Working with JSON/YAML/XML configuration
- Performing code refactoring
- Building interactive CLI workflows
- Needing to select from multiple results

## Prerequisites

The skill assumes these tools are installed:

- fd
- rg (ripgrep)
- ast-grep
- fzf
- jq
- yq

Installation varies by platform (Homebrew on macOS, apt/dnf on Linux, etc.)

## Total Package Size

94.5 KB (9 files)

## Development

### Trigger CI

- Activates when you push a tag matching the pattern v*.*.* (e.g., v0.1.0, v1.2.3)

### Features

1. **Automatic version detection** - Extracts version number from the git tag
2. **Version metadata update** - Automatically updates the `version:` field in `cli-ninja/SKILL.md` to match the release tag
3. **Zip packaging** - Creates `cli-ninja-{VERSION}.zip` containing the entire cli-ninja directory with updated version
4. **GitHub Release creation** - Automatically creates a release with:
   - Descriptive title and body
   - Tool overview and installation instructions
   - Optional changelog support (if CHANGELOG.md exists)
   - The zip file as a downloadable asset

### Usage

To create your first release (v0.1.0):

```bash
git add .github/workflows/release.yml
git commit -m "Add release workflow for packaging cli-ninja skill"
git tag v0.1.0
git push origin main
git push origin v0.1.0
```

The workflow will automatically:

1. Update `version: 0.1.0` in cli-ninja/SKILL.md
2. Package cli-ninja/ into cli-ninja-0.1.0.zip (with the updated version)
3. Create a GitHub release named "cli-ninja v0.1.0"
4. Attach the zip file to the release
5. Include formatted installation instructions

For subsequent releases, just create and push new tags (e.g., v0.2.0, v1.0.0). The version in SKILL.md will automatically match the tag.
