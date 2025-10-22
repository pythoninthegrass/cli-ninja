#!/usr/bin/env bash
#
# combo-search.sh - Example combination workflows using CLI tools
#
# This script demonstrates common patterns for combining fd, rg, ast-grep,
# fzf, jq, and yq to solve real-world repository navigation tasks.

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper function to print section headers
print_section() {
  echo -e "\n${BLUE}=== $1 ===${NC}\n"
}

# Helper function to print commands before execution
print_command() {
  echo -e "${YELLOW}$ $1${NC}"
}

# 1. Find Python files with TODO comments, select one, and edit
find_and_edit_todos() {
  print_section "Find and Edit TODOs"
  print_command "rg -l 'TODO' -t py | fzf --preview 'rg -C 3 --color=always TODO {}' | xargs \$EDITOR"

  local file
  file=$(rg -l 'TODO' -t py | fzf --preview 'rg -C 3 --color=always TODO {}' || true)

  if [[ -n "$file" ]]; then
    echo -e "${GREEN}Selected: $file${NC}"
    # Uncomment to actually open editor:
    # $EDITOR "$file"
  else
    echo -e "${RED}No file selected${NC}"
  fi
}

# 2. Find function definitions, select one, and show its usages
find_function_usages() {
  print_section "Find Function and Its Usages"

  local func_pattern="def $1(\$\$\$):"

  print_command "ast-grep --pattern '$func_pattern' -l py | fzf"

  local result
  result=$(ast-grep --pattern "$func_pattern" -l py | fzf --preview 'bat --color=always {1}' || true)

  if [[ -n "$result" ]]; then
    local func_name
    func_name=$(echo "$result" | sed -n 's/.*def \([^(]*\)(.*/\1/p')

    echo -e "${GREEN}Function: $func_name${NC}"
    echo -e "${YELLOW}Usages:${NC}"

    print_command "rg '\\b$func_name\\(' -t py"
    rg "\b$func_name\(" -t py || echo "No usages found"
  fi
}

# 3. Find configuration files and edit selected one
edit_config_file() {
  print_section "Find and Edit Configuration File"

  print_command "fd -e json -e yaml -e toml config | fzf --preview 'bat --color=always {}'"

  local config
  config=$(fd -e json -e yaml -e toml config | fzf --preview 'bat --color=always {}' || true)

  if [[ -n "$config" ]]; then
    echo -e "${GREEN}Selected: $config${NC}"
    # Uncomment to actually open editor:
    # $EDITOR "$config"
  else
    echo -e "${RED}No config selected${NC}"
  fi
}

# 4. Search for imports of a module and show file list
find_module_imports() {
  print_section "Find Module Imports"

  local module="$1"

  print_command "ast-grep --pattern 'from $module import \$\$\$' -l py"
  print_command "ast-grep --pattern 'import $module' -l py"

  echo -e "${YELLOW}Files importing $module:${NC}"
  {
    ast-grep --pattern "from $module import \$\$\$" -l py 2>/dev/null || true
    ast-grep --pattern "import $module" -l py 2>/dev/null || true
  } | sort -u
}

# 5. Find recently modified files and select for editing
edit_recent_file() {
  print_section "Find and Edit Recently Modified File"

  print_command "fd -t f --changed-within 7d | fzf --preview 'bat --color=always {}'"

  local file
  file=$(fd -t f --changed-within 7d | fzf --preview 'bat --color=always {}' || true)

  if [[ -n "$file" ]]; then
    echo -e "${GREEN}Selected: $file${NC}"
    # Uncomment to actually open editor:
    # $EDITOR "$file"
  else
    echo -e "${RED}No file selected${NC}"
  fi
}

# 6. Find JSON files and explore with jq
explore_json_files() {
  print_section "Find and Explore JSON Files"

  print_command "fd -e json | fzf --preview 'jq --color-output . {}'"

  local json_file
  json_file=$(fd -e json | fzf --preview 'jq --color-output . {}' || true)

  if [[ -n "$json_file" ]]; then
    echo -e "${GREEN}Selected: $json_file${NC}"
    echo -e "${YELLOW}Keys:${NC}"
    jq 'keys' "$json_file"
  else
    echo -e "${RED}No JSON file selected${NC}"
  fi
}

# 7. Find test files with failures
find_failing_tests() {
  print_section "Find Test Files with 'FAIL' or 'ERROR'"

  print_command "rg -l '(FAIL|ERROR)' tests/ -t py | fzf --preview 'rg -C 5 --color=always \"(FAIL|ERROR)\" {}'"

  local test_file
  test_file=$(rg -l '(FAIL|ERROR)' tests/ -t py 2>/dev/null | \
    fzf --preview 'rg -C 5 --color=always "(FAIL|ERROR)" {}' || true)

  if [[ -n "$test_file" ]]; then
    echo -e "${GREEN}Selected: $test_file${NC}"
  else
    echo -e "${RED}No failing tests found or none selected${NC}"
  fi
}

# 8. Find and count function definitions by file
count_functions_per_file() {
  print_section "Count Function Definitions Per File"

  print_command "ast-grep --pattern 'def \$FUNC(\$\$\$):' -l py | xargs -I {} sh -c 'echo \"{}: \$(ast-grep --pattern \"def \\\$FUNC(\\\$\\\$\\\$):\" {} | wc -l)\"'"

  ast-grep --pattern 'def $FUNC($$$):' -l py 2>/dev/null | \
    xargs -I {} sh -c 'echo "{}: $(ast-grep --pattern "def \$FUNC(\$\$\$):" {} | wc -l)"' | \
    sort -t: -k2 -nr | \
    head -10
}

# 9. Find all TODO/FIXME comments and group by file
list_todos_by_file() {
  print_section "List TODOs/FIXMEs Grouped by File"

  print_command "rg -n '(TODO|FIXME|XXX|HACK):' | sort | fzf --preview 'bat --color=always {1} --highlight-line {2}'"

  rg -n '(TODO|FIXME|XXX|HACK):' 2>/dev/null | \
    sort | \
    fzf --preview 'bat --color=always {1} --highlight-line {2}' || true
}

# 10. Interactive refactoring: find pattern and preview replacement
interactive_refactor() {
  print_section "Interactive Refactoring Preview"

  local old_pattern="$1"
  local new_pattern="$2"

  print_command "ast-grep --pattern '$old_pattern' -l py | fzf -m --preview 'ast-grep --pattern \"$old_pattern\" {}'"

  local files
  files=$(ast-grep --pattern "$old_pattern" -l py 2>/dev/null | \
    fzf -m --preview "ast-grep --pattern '$old_pattern' {}" || true)

  if [[ -n "$files" ]]; then
    echo -e "${GREEN}Selected files for refactoring:${NC}"
    echo "$files"
    echo -e "\n${YELLOW}To apply refactoring, run:${NC}"
    echo -e "ast-grep --pattern '$old_pattern' --rewrite '$new_pattern' -l py --interactive"
  else
    echo -e "${RED}No files selected${NC}"
  fi
}

# Main menu
show_menu() {
  echo -e "\n${BLUE}CLI Ninja - Combination Workflows${NC}\n"
  echo "1. Find and edit TODOs"
  echo "2. Find function usages (requires function name)"
  echo "3. Edit config file"
  echo "4. Find module imports (requires module name)"
  echo "5. Edit recently modified file"
  echo "6. Explore JSON files"
  echo "7. Find failing tests"
  echo "8. Count functions per file"
  echo "9. List TODOs/FIXMEs"
  echo "10. Interactive refactoring preview (requires old/new patterns)"
  echo "0. Exit"
  echo
}

# Main execution
main() {
  if [[ $# -eq 0 ]]; then
    show_menu
    read -rp "Select workflow: " choice

    case $choice in
      1) find_and_edit_todos ;;
      2)
        read -rp "Enter function name: " func
        find_function_usages "$func"
        ;;
      3) edit_config_file ;;
      4)
        read -rp "Enter module name: " module
        find_module_imports "$module"
        ;;
      5) edit_recent_file ;;
      6) explore_json_files ;;
      7) find_failing_tests ;;
      8) count_functions_per_file ;;
      9) list_todos_by_file ;;
      10)
        read -rp "Enter old pattern: " old
        read -rp "Enter new pattern: " new
        interactive_refactor "$old" "$new"
        ;;
      0) exit 0 ;;
      *) echo -e "${RED}Invalid choice${NC}" ;;
    esac
  else
    # Direct command execution
    case "$1" in
      todos) find_and_edit_todos ;;
      function)
        [[ $# -ge 2 ]] || { echo "Usage: $0 function <name>"; exit 1; }
        find_function_usages "$2"
        ;;
      config) edit_config_file ;;
      imports)
        [[ $# -ge 2 ]] || { echo "Usage: $0 imports <module>"; exit 1; }
        find_module_imports "$2"
        ;;
      recent) edit_recent_file ;;
      json) explore_json_files ;;
      failing) find_failing_tests ;;
      count) count_functions_per_file ;;
      list-todos) list_todos_by_file ;;
      refactor)
        [[ $# -ge 3 ]] || { echo "Usage: $0 refactor <old> <new>"; exit 1; }
        interactive_refactor "$2" "$3"
        ;;
      *)
        echo "Usage: $0 [command] [args]"
        echo "Run without arguments for interactive menu"
        exit 1
        ;;
    esac
  fi
}

main "$@"
