#!/usr/bin/env bash
#
# interactive-code-finder.sh - Interactive ast-grep + fzf workflow
#
# This script provides an interactive way to search for code patterns
# using ast-grep and select results with fzf for further action.

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuration
LANGUAGE="${LANGUAGE:-py}"
PREVIEW_LINES=20

# Helper functions
print_header() {
  echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${BLUE}  $1${NC}"
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
}

print_success() {
  echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
  echo -e "${RED}✗ $1${NC}"
}

print_info() {
  echo -e "${CYAN}ℹ $1${NC}"
}

print_warning() {
  echo -e "${YELLOW}⚠ $1${NC}"
}

# Check dependencies
check_dependencies() {
  local missing=()

  for cmd in ast-grep fzf bat; do
    if ! command -v "$cmd" &> /dev/null; then
      missing+=("$cmd")
    fi
  done

  if [[ ${#missing[@]} -gt 0 ]]; then
    print_error "Missing required tools: ${missing[*]}"
    echo
    echo "Install with:"
    echo "  brew install ast-grep fzf bat"
    exit 1
  fi
}

# Language-specific pattern examples
get_pattern_examples() {
  local lang="$1"

  case "$lang" in
    py|python)
      cat <<EOF
Function definitions:    def \$FUNC(\$\$\$):
Class definitions:       class \$CLASS:
Function calls:          \$FUNC(\$\$\$)
Method calls:            \$OBJ.\$METHOD(\$\$\$)
Imports:                 from \$MOD import \$\$\$
Decorators:              @\$DECORATOR
If statements:           if \$COND:
For loops:               for \$VAR in \$ITER:
Try/except:              try: \$\$\$ except \$EXC: \$\$\$
Context managers:        with \$EXPR as \$VAR:
EOF
      ;;
    js|javascript|ts|typescript)
      cat <<EOF
Function declarations:   function \$FUNC(\$\$\$) { \$\$\$ }
Arrow functions:         (\$\$\$) => \$BODY
Class definitions:       class \$CLASS { \$\$\$ }
Imports:                 import \$\$ from "\$MODULE"
Export default:          export default \$EXPR
React components:        function \$COMP() { \$\$\$ }
useState:                const [\$STATE, \$SETTER] = useState(\$\$\$)
Async functions:         async function \$FUNC(\$\$\$) { \$\$\$ }
EOF
      ;;
    rs|rust)
      cat <<EOF
Function definitions:    fn \$FUNC(\$\$\$) { \$\$\$ }
Struct definitions:      struct \$NAME { \$\$\$ }
Impl blocks:             impl \$TYPE { \$\$\$ }
Trait impl:              impl \$TRAIT for \$TYPE { \$\$\$ }
Macros:                  \$MACRO!(\$\$\$)
Match expressions:       match \$EXPR { \$\$\$ }
Result returns:          fn \$FUNC(\$\$\$) -> Result<\$\$\$> { \$\$\$ }
EOF
      ;;
    go)
      cat <<EOF
Function definitions:    func \$FUNC(\$\$\$) \$\$\$ { \$\$\$ }
Method definitions:      func (\$RECV \$TYPE) \$METHOD(\$\$\$) \$\$\$ { \$\$\$ }
Struct definitions:      type \$NAME struct { \$\$\$ }
Interface definitions:   type \$NAME interface { \$\$\$ }
Goroutines:              go \$FUNC(\$\$\$)
Defer statements:        defer \$FUNC(\$\$\$)
Error checks:            if err != nil { \$\$\$ }
EOF
      ;;
    zig)
      cat <<EOF
Public functions:        pub fn \$FUNC(\$\$\$) \$\$\$ { \$\$\$ }
Struct definitions:      const \$NAME = struct { \$\$\$ };
Error handling:          try \$EXPR
Test blocks:             test "\$NAME" { \$\$\$ }
Comptime:                comptime \$EXPR
EOF
      ;;
    rb|ruby)
      cat <<EOF
Method definitions:      def \$METHOD(\$\$\$); \$\$\$; end
Class definitions:       class \$CLASS; \$\$\$; end
Blocks with do/end:      \$EXPR do |\$PARAM|; \$\$\$; end
Blocks with braces:      \$EXPR { |\$PARAM| \$\$\$ }
Rails routes:            get "\$PATH", to: "\$HANDLER"
ActiveRecord queries:    \$MODEL.where(\$\$\$)
EOF
      ;;
    *)
      echo "Generic pattern: \$PATTERN"
      ;;
  esac
}

# Show pattern examples
show_examples() {
  print_header "Pattern Examples for $LANGUAGE"
  get_pattern_examples "$LANGUAGE"
  echo
}

# Interactive pattern input
get_pattern() {
  show_examples

  print_info "Enter your ast-grep pattern (or 'examples' to see more):"
  echo -e "${YELLOW}Examples:${NC}"
  echo "  - def \$FUNC(\$\$\$):"
  echo "  - class \$CLASS:"
  echo "  - \$FUNC(\$\$\$)"
  echo

  read -rp "Pattern: " pattern

  if [[ "$pattern" == "examples" ]]; then
    show_examples
    get_pattern
    return
  fi

  if [[ -z "$pattern" ]]; then
    print_error "Pattern cannot be empty"
    exit 1
  fi

  echo "$pattern"
}

# Search with ast-grep and show results with fzf
search_pattern() {
  local pattern="$1"
  local lang="$2"

  print_info "Searching for: $pattern"
  echo

  # Create temporary file for results
  local results
  results=$(mktemp)

  # Run ast-grep and save results
  if ! ast-grep --pattern "$pattern" -l "$lang" > "$results" 2>&1; then
    print_error "ast-grep search failed"
    cat "$results"
    rm "$results"
    exit 1
  fi

  # Check if we have results
  if [[ ! -s "$results" ]]; then
    print_warning "No matches found for pattern: $pattern"
    rm "$results"
    exit 0
  fi

  # Count results
  local count
  count=$(wc -l < "$results")
  print_success "Found $count match(es)"
  echo

  # Interactive selection with fzf
  local selected
  selected=$(cat "$results" | fzf \
    --preview "bat --color=always --highlight-line {2} {1}" \
    --preview-window=right:60%:wrap \
    --delimiter : \
    --prompt "Select file > " \
    --header "Press Enter to open, Ctrl-Y to copy path, Ctrl-C to exit" \
    --bind "ctrl-y:execute-silent(echo {1} | pbcopy)+abort" \
    --bind "ctrl-/:toggle-preview" \
    --height=100% \
    || true)

  rm "$results"

  if [[ -z "$selected" ]]; then
    print_info "No file selected"
    exit 0
  fi

  # Extract file path and line number
  local file line
  file=$(echo "$selected" | cut -d: -f1)
  line=$(echo "$selected" | cut -d: -f2)

  # Show action menu
  show_action_menu "$file" "$line" "$pattern" "$lang"
}

# Action menu for selected file
show_action_menu() {
  local file="$1"
  local line="$2"
  local pattern="$3"
  local lang="$4"

  print_header "Selected: $file:$line"

  echo "What would you like to do?"
  echo
  echo "1. Open in editor (\$EDITOR)"
  echo "2. Show context (20 lines)"
  echo "3. Show all matches in file"
  echo "4. Copy file path to clipboard"
  echo "5. Find usages of pattern in project"
  echo "6. Exit"
  echo

  read -rp "Choice: " choice

  case "$choice" in
    1)
      print_info "Opening $file at line $line..."
      ${EDITOR:-vim} "+$line" "$file"
      ;;
    2)
      print_header "Context around $file:$line"
      bat --color=always --highlight-line "$line" --line-range "$((line-10)):$((line+10))" "$file"
      ;;
    3)
      print_header "All matches in $file"
      ast-grep --pattern "$pattern" -l "$lang" "$file"
      ;;
    4)
      echo -n "$file" | pbcopy
      print_success "Copied to clipboard: $file"
      ;;
    5)
      print_header "Finding usages in project..."
      # Extract the identifier from the pattern
      local identifier
      identifier=$(echo "$pattern" | grep -oE '\$[A-Z_]+' | head -1 | sed 's/\$//')
      if [[ -n "$identifier" ]]; then
        print_info "Searching for references to: $identifier"
        rg "\b$identifier\b" -t "$lang"
      else
        print_warning "Could not extract identifier from pattern"
      fi
      ;;
    6)
      print_info "Exiting..."
      exit 0
      ;;
    *)
      print_error "Invalid choice"
      show_action_menu "$file" "$line" "$pattern" "$lang"
      ;;
  esac
}

# Multi-pattern search mode
multi_pattern_search() {
  print_header "Multi-Pattern Search"

  print_info "Enter patterns (one per line, empty line to finish):"
  local patterns=()

  while true; do
    read -rp "Pattern $(( ${#patterns[@]} + 1 )): " pattern
    if [[ -z "$pattern" ]]; then
      break
    fi
    patterns+=("$pattern")
  done

  if [[ ${#patterns[@]} -eq 0 ]]; then
    print_error "No patterns provided"
    exit 1
  fi

  print_info "Searching for ${#patterns[@]} pattern(s)..."

  local all_results
  all_results=$(mktemp)

  for pattern in "${patterns[@]}"; do
    ast-grep --pattern "$pattern" -l "$LANGUAGE" >> "$all_results" 2>&1 || true
  done

  # Remove duplicates and sort
  sort -u "$all_results" | fzf \
    --preview "bat --color=always {1}" \
    --preview-window=right:60%:wrap \
    --delimiter : \
    --multi \
    --prompt "Select files > " \
    --header "Tab to select multiple, Enter to confirm" \
    --bind "ctrl-a:select-all" \
    --bind "ctrl-d:deselect-all" \
    --height=100% \
    || true

  rm "$all_results"
}

# Help message
show_help() {
  cat <<EOF
${BLUE}Interactive Code Finder${NC}

Usage: $0 [OPTIONS]

Options:
  -p, --pattern PATTERN   Search for specific pattern
  -l, --language LANG     Set language (default: py)
  -m, --multi             Multi-pattern search mode
  -e, --examples          Show pattern examples and exit
  -h, --help              Show this help message

Languages:
  py, python              Python
  js, javascript          JavaScript
  ts, typescript          TypeScript
  rs, rust                Rust
  go                      Go
  zig                     Zig
  rb, ruby                Ruby

Examples:
  $0                                  # Interactive mode
  $0 -p "def \$FUNC(\$\$\$):"         # Search for Python functions
  $0 -l js -p "function \$F(\$\$\$)"  # Search for JS functions
  $0 -m                               # Multi-pattern search
  $0 -e                               # Show pattern examples

Pattern Syntax:
  \$VAR       - Single node (identifier, expression)
  \$\$\$       - Zero or more nodes (variadic)
  \$\$        - Statement sequence

EOF
}

# Main function
main() {
  local pattern=""
  local multi_mode=false

  # Check dependencies first
  check_dependencies

  # Parse arguments
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -p|--pattern)
        pattern="$2"
        shift 2
        ;;
      -l|--language)
        LANGUAGE="$2"
        shift 2
        ;;
      -m|--multi)
        multi_mode=true
        shift
        ;;
      -e|--examples)
        show_examples
        exit 0
        ;;
      -h|--help)
        show_help
        exit 0
        ;;
      *)
        print_error "Unknown option: $1"
        show_help
        exit 1
        ;;
    esac
  done

  # Multi-pattern mode
  if [[ "$multi_mode" == true ]]; then
    multi_pattern_search
    exit 0
  fi

  # Get pattern if not provided
  if [[ -z "$pattern" ]]; then
    pattern=$(get_pattern)
  fi

  # Search
  search_pattern "$pattern" "$LANGUAGE"
}

main "$@"
