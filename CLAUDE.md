# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

cli-ninja is a Claude Code skill that provides guidance for CLI navigation and code exploration using modern command-line tools: `fd`, `rg` (ripgrep), `ast-grep`, `fzf`, `jq`, and `yq`. The skill is distributed as a Claude Code plugin via marketplace or direct installation.

## Repository Structure

```bash
cli-ninja/
├── SKILL.md                            # Main skill definition (12.4 KB)
├── references/                         # Comprehensive tool guides (63 KB)
│   ├── fd-patterns.md                  # File finding patterns
│   ├── rg-patterns.md                  # Text search patterns
│   ├── ast-grep-guide.md               # Code structure search (Python, JS/TS, Rust, Go, Zig, Ruby)
│   ├── fzf-workflows.md                 # Interactive selection patterns
│   ├── jq-cookbook.md                  # JSON processing examples
│   └── yq-examples.md                  # YAML/XML processing examples
└── scripts/                            # Reusable workflow examples (18.9 KB)
    ├── combo-search.sh                 # 10 common combination workflows
    └── interactive-code-finder.sh       # Interactive ast-grep + fzf tool

.claude-plugin/
└── marketplace.json                    # Plugin marketplace configuration

.github/
└── workflows/
    └── release-please.yml              # Automated release workflow
```

### Key Files

- **SKILL.md**: Main skill file that gets loaded when users invoke `/cli-ninja`. Contains tool selection decision tree, quick references, combination workflows, and best practices.
- **references/**: Deep-dive guides for each tool with comprehensive patterns and examples.
- **scripts/**: Executable bash scripts demonstrating real-world tool combinations.
- **marketplace.json**: Plugin metadata for Claude Code marketplace distribution.

## Development Workflow

### Version Management

This project uses [Release Please](https://github.com/googleapis/release-please) for automated releases based on [Conventional Commits](https://www.conventionalcommits.org/).

**Commit format:**
```bash
feat: add new ast-grep pattern for Python decorators  # Minor version bump
fix: correct fd pattern for hidden files                # Patch version bump
docs: update installation instructions                # No version bump
chore: update workflow dependencies                    # No version bump
```

**Breaking changes:**
```bash
feat!: redesign skill structure
# or
feat: major refactor

BREAKING CHANGE: skill structure has changed
```

### Release Process

1. **Commit changes** using conventional commit format
2. **Push to main** - Release Please automatically creates a PR with:
   - Updated CHANGELOG.md
   - Version bump in `.release-please-manifest.json`
3. **Merge the PR** - Triggers release workflow that:
   - Creates git tag
   - Creates GitHub Release
   - Updates `marketplace.json` version
   - Packages `cli-ninja/` directory as `cli-ninja-{VERSION}.zip`
   - Uploads zip to GitHub Release

**Current version**: Check `.release-please-manifest.json`

### Testing Workflow Changes

Before committing changes to SKILL.md or reference files:

1. Test the skill loads correctly in Claude Code
2. Verify tool examples work as documented
3. Ensure bash scripts in `scripts/` are executable and run without errors
4. Check that file sizes stay reasonable (total package ~95KB target)

### Content Guidelines

**SKILL.md**:

- Keep under ~15KB for quick loading
- Maintain clear decision tree at top
- Include practical examples, not just syntax
- Reference detailed patterns in `references/` files

**references/**:

- Each file focuses on one tool
- Include copy-paste ready examples
- Cover language-specific patterns (Python, JS/TS, Rust, Go, Zig, Ruby)
- Explain when to use each flag/option

**scripts/**:

- Must be executable (`chmod +x`)
- Include clear comments and section headers
- Demonstrate tool combinations, not single-tool usage
- Use shellcheck-compliant bash

### Adding New Tool Patterns

When adding support for a new language or tool pattern:

1. Add basic pattern to SKILL.md quick reference
2. Add comprehensive examples to appropriate `references/*.md` file
3. If pattern requires multiple tools, add example to `scripts/combo-search.sh`
4. Update tool selection decision tree if adding new tool category

### Plugin Marketplace Updates

The `.claude-plugin/marketplace.json` file is automatically updated during releases. Manual updates should maintain:

- Version sync with `.release-please-manifest.json`
- Keywords relevant to CLI tools and developer workflows
- Category: `developer-tools`

## Common Commands

```bash
# Test skill locally (from repo root)
/plugin install .

# Package manually (matches CI process)
cd cli-ninja && zip -r ../cli-ninja-test.zip . && cd ..

# Validate JSON files
jq . .claude-plugin/marketplace.json
jq . .release-please-manifest.json
jq . release-please-config.json

# Check script syntax
shellcheck cli-ninja/scripts/*.sh

# View skill size
du -sh cli-ninja/

# Count total files
find cli-ninja -type f | wc -l

# Test specific tool examples (requires tools installed)
fd -e md                          # Find markdown files
rg 'ast-grep' -t md               # Search in markdown
ast-grep --pattern 'def $F($$$)'  # Find Python functions (requires .py files)
```

## Architecture Notes

### Skill Loading

When users invoke `/cli-ninja`, Claude Code:

1. Loads `cli-ninja/SKILL.md` frontmatter (name, description)
2. Injects full SKILL.md content into Claude's context
3. Makes `references/` and `scripts/` available as resources

The skill provides **guidance**, not executable tools. Claude interprets the patterns and helps users construct appropriate commands.

### Tool Selection Philosophy

The skill follows a "right tool for the job" philosophy:

- **fd** for file system navigation (faster than find)
- **rg** for text content (faster than grep)
- **ast-grep** for code structure (smarter than regex)
- **fzf** for interactive selection (better UX than piping to less)
- **jq/yq** for structured data (safer than text parsing)

### Combination Patterns

Most value comes from **combining** tools via pipes:
```bash
# Pattern: Search → Select → Act
rg -l 'pattern' | fzf --preview 'bat {}' | xargs $EDITOR

# Pattern: Find → Filter → Process
fd -e json | fzf | xargs jq '.field'

# Pattern: Structure → Refactor
ast-grep --pattern 'old($$$)' --rewrite 'new($$$)' --interactive
```

The skill emphasizes these combinations in examples and workflows.

## Distribution

**Primary**: Claude Code marketplace (`/plugin install cli-ninja@pythoninthegrass/cli-ninja`)
**Secondary**: GitHub Releases (manual zip download)

The skill package is just the `cli-ninja/` directory - no build step, no dependencies, pure markdown and bash.
