# ast-grep - Code Structure Search Guide

## Overview

`ast-grep` searches code by Abstract Syntax Tree (AST) structure, not text. It understands code semantics and can find patterns that are impossible with regex.

## Core Concepts

### Pattern Syntax

- `$VAR` - Matches a single AST node (identifier, expression, etc.)
- `$$$` - Matches zero or more nodes (variadic)
- `$$` - Matches a sequence of statements

### Pattern Matching Philosophy

ast-grep matches **structure**, not **text**:

```bash
# This finds ALL function calls to 'print', regardless of arguments
ast-grep --pattern 'print($$$)'

# Matches:
# print()
# print("hello")
# print("hello", "world")
# print(x, y, z)
```

## Language Support

ast-grep supports: Python, JavaScript, TypeScript, Rust, Go, Java, C, C++, C#, Ruby, Kotlin, Swift, and more.

---

## Python Patterns

### Function Definitions

```bash
# Any function
ast-grep --pattern 'def $FUNC($$$): $$$' -l py

# Functions with no parameters
ast-grep --pattern 'def $FUNC(): $$$' -l py

# Functions with specific number of parameters
ast-grep --pattern 'def $FUNC($A, $B): $$$' -l py

# Functions with type hints
ast-grep --pattern 'def $FUNC($$$) -> $TYPE: $$$' -l py

# Async functions
ast-grep --pattern 'async def $FUNC($$$): $$$' -l py

# Methods (functions with self)
ast-grep --pattern 'def $METHOD(self, $$$): $$$' -l py

# Class methods
ast-grep --pattern '@classmethod' -A 1 -l py

# Static methods
ast-grep --pattern '@staticmethod' -A 1 -l py
```

### Class Definitions

```bash
# Any class
ast-grep --pattern 'class $CLASS: $$$' -l py

# Class with inheritance
ast-grep --pattern 'class $CLASS($BASE): $$$' -l py

# Class with multiple inheritance
ast-grep --pattern 'class $CLASS($$$): $$$' -l py

# Dataclass
ast-grep --pattern '@dataclass' -A 1 -l py
```

### Imports

```bash
# Import statements
ast-grep --pattern 'import $MODULE' -l py

# From imports
ast-grep --pattern 'from $MODULE import $$$' -l py

# Specific import
ast-grep --pattern 'from $MODULE import $NAME' -l py

# Relative imports
ast-grep --pattern 'from . import $$$' -l py
ast-grep --pattern 'from .. import $$$' -l py

# Import aliases
ast-grep --pattern 'import $MODULE as $ALIAS' -l py
```

### Function Calls

```bash
# Any call to a function
ast-grep --pattern '$FUNC($$$)' -l py

# Method calls
ast-grep --pattern '$OBJ.$METHOD($$$)' -l py

# Chained method calls
ast-grep --pattern '$OBJ.$M1().$M2($$$)' -l py

# Specific function calls
ast-grep --pattern 'print($$$)' -l py
ast-grep --pattern 'open($$$)' -l py
```

### Control Flow

```bash
# If statements
ast-grep --pattern 'if $COND: $$$' -l py

# For loops
ast-grep --pattern 'for $VAR in $ITER: $$$' -l py

# While loops
ast-grep --pattern 'while $COND: $$$' -l py

# Try/except
ast-grep --pattern 'try: $$$ except $EXC: $$$' -l py

# Context managers
ast-grep --pattern 'with $EXPR as $VAR: $$$' -l py
```

### Decorators

```bash
# Any decorator
ast-grep --pattern '@$DECORATOR' -l py

# Specific decorator
ast-grep --pattern '@property' -l py
ast-grep --pattern '@staticmethod' -l py

# Decorator with arguments
ast-grep --pattern '@$DECORATOR($$$)' -l py
```

---

## JavaScript/TypeScript Patterns

### Function Definitions

```bash
# Function declarations
ast-grep --pattern 'function $FUNC($$$) { $$$ }' -l js

# Arrow functions
ast-grep --pattern '($$$) => $BODY' -l js
ast-grep --pattern '$VAR = ($$$) => { $$$ }' -l js

# Async functions
ast-grep --pattern 'async function $FUNC($$$) { $$$ }' -l js
ast-grep --pattern 'async ($$$) => $BODY' -l js

# Generator functions
ast-grep --pattern 'function* $FUNC($$$) { $$$ }' -l js
```

### Class and Components

```bash
# Class declarations
ast-grep --pattern 'class $CLASS { $$$ }' -l js

# Class with extends
ast-grep --pattern 'class $CLASS extends $BASE { $$$ }' -l js

# React functional components
ast-grep --pattern 'function $COMP() { $$$ }' -l tsx
ast-grep --pattern 'const $COMP = () => { $$$ }' -l tsx

# React class components
ast-grep --pattern 'class $COMP extends React.Component { $$$ }' -l tsx
```

### Imports/Exports

```bash
# Import statements
ast-grep --pattern 'import $$ from "$MODULE"' -l js

# Named imports
ast-grep --pattern 'import { $$ } from "$MODULE"' -l js

# Default import
ast-grep --pattern 'import $DEFAULT from "$MODULE"' -l js

# Require (CommonJS)
ast-grep --pattern 'require("$MODULE")' -l js

# Export default
ast-grep --pattern 'export default $EXPR' -l js

# Named exports
ast-grep --pattern 'export { $$ }' -l js
```

### React Hooks

```bash
# useState
ast-grep --pattern 'const [$STATE, $SETTER] = useState($$$)' -l tsx

# useEffect
ast-grep --pattern 'useEffect($$$)' -l tsx

# useCallback
ast-grep --pattern 'useCallback($$$)' -l tsx

# useMemo
ast-grep --pattern 'useMemo($$$)' -l tsx

# Custom hooks (by convention)
ast-grep --pattern 'function use$HOOK($$$) { $$$ }' -l tsx
```

### TypeScript Specifics

```bash
# Type definitions
ast-grep --pattern 'type $NAME = $TYPE' -l ts

# Interface definitions
ast-grep --pattern 'interface $NAME { $$$ }' -l ts

# Type assertions
ast-grep --pattern '$EXPR as $TYPE' -l ts

# Generic functions
ast-grep --pattern 'function $FUNC<$$$>($$$) { $$$ }' -l ts
```

---

## Rust Patterns

### Function Definitions

```bash
# Function declarations
ast-grep --pattern 'fn $FUNC($$$) { $$$ }' -l rs

# Functions with return type
ast-grep --pattern 'fn $FUNC($$$) -> $TYPE { $$$ }' -l rs

# Public functions
ast-grep --pattern 'pub fn $FUNC($$$) { $$$ }' -l rs

# Async functions
ast-grep --pattern 'async fn $FUNC($$$) { $$$ }' -l rs

# Unsafe functions
ast-grep --pattern 'unsafe fn $FUNC($$$) { $$$ }' -l rs
```

### Structs and Enums

```bash
# Struct definitions
ast-grep --pattern 'struct $NAME { $$$ }' -l rs

# Tuple structs
ast-grep --pattern 'struct $NAME($$$);' -l rs

# Enum definitions
ast-grep --pattern 'enum $NAME { $$$ }' -l rs

# Public structs
ast-grep --pattern 'pub struct $NAME { $$$ }' -l rs
```

### Impl Blocks

```bash
# Implementation blocks
ast-grep --pattern 'impl $TYPE { $$$ }' -l rs

# Trait implementations
ast-grep --pattern 'impl $TRAIT for $TYPE { $$$ }' -l rs

# Generic implementations
ast-grep --pattern 'impl<$$$> $TYPE { $$$ }' -l rs
```

### Macros

```bash
# Macro usage
ast-grep --pattern '$MACRO!($$$)' -l rs

# Specific macros
ast-grep --pattern 'println!($$$)' -l rs
ast-grep --pattern 'vec![$$$]' -l rs

# Macro definitions
ast-grep --pattern 'macro_rules! $NAME { $$$ }' -l rs
```

### Error Handling

```bash
# Result returns
ast-grep --pattern 'fn $FUNC($$$) -> Result<$$$> { $$$ }' -l rs

# Unwrap calls
ast-grep --pattern '$EXPR.unwrap()' -l rs

# Question mark operator
ast-grep --pattern '$EXPR?' -l rs

# Match Result
ast-grep --pattern 'match $EXPR { Ok($VAL) => $$$, Err($ERR) => $$$ }' -l rs
```

---

## Go Patterns

### Function Definitions

```bash
# Function declarations
ast-grep --pattern 'func $FUNC($$$) $$$ { $$$ }' -l go

# Methods
ast-grep --pattern 'func ($RECV $TYPE) $METHOD($$$) $$$ { $$$ }' -l go

# Functions with multiple returns
ast-grep --pattern 'func $FUNC($$$) ($$$, error) { $$$ }' -l go
```

### Struct and Interface

```bash
# Struct definitions
ast-grep --pattern 'type $NAME struct { $$$ }' -l go

# Interface definitions
ast-grep --pattern 'type $NAME interface { $$$ }' -l go

# Type aliases
ast-grep --pattern 'type $NAME $TYPE' -l go
```

### Concurrency

```bash
# Goroutine launches
ast-grep --pattern 'go $FUNC($$$)' -l go

# Channel operations
ast-grep --pattern '$CHAN <- $VALUE' -l go
ast-grep --pattern '$VAR := <-$CHAN' -l go

# Select statements
ast-grep --pattern 'select { $$$ }' -l go
```

### Error Handling

```bash
# If err check
ast-grep --pattern 'if err != nil { $$$ }' -l go

# Error returns
ast-grep --pattern 'return $$$, err' -l go

# Defer statements
ast-grep --pattern 'defer $FUNC($$$)' -l go
```

---

## Zig Patterns

### Function Definitions

```bash
# Public functions
ast-grep --pattern 'pub fn $FUNC($$$) $$$ { $$$ }' -l zig

# Private functions
ast-grep --pattern 'fn $FUNC($$$) $$$ { $$$ }' -l zig

# Exported functions
ast-grep --pattern 'export fn $FUNC($$$) $$$ { $$$ }' -l zig
```

### Structs and Types

```bash
# Struct definitions
ast-grep --pattern 'const $NAME = struct { $$$ };' -l zig

# Packed structs
ast-grep --pattern 'const $NAME = packed struct { $$$ };' -l zig

# Type definitions
ast-grep --pattern 'const $NAME = $TYPE;' -l zig
```

### Error Handling

```bash
# Try expressions
ast-grep --pattern 'try $EXPR' -l zig

# Catch
ast-grep --pattern '$EXPR catch $$$' -l zig

# Error unions
ast-grep --pattern 'fn $FUNC($$$) !$$$ { $$$ }' -l zig
```

### Testing

```bash
# Test blocks
ast-grep --pattern 'test "$NAME" { $$$ }' -l zig

# Expect calls
ast-grep --pattern 'try testing.expect($$$)' -l zig
```

---

## Ruby Patterns

### Method Definitions

```bash
# Method definitions
ast-grep --pattern 'def $METHOD($$$); $$$; end' -l rb

# Class methods
ast-grep --pattern 'def self.$METHOD($$$); $$$; end' -l rb

# Private methods
ast-grep --pattern 'private' -A 1 -l rb
```

### Classes and Modules

```bash
# Class definitions
ast-grep --pattern 'class $CLASS; $$$; end' -l rb

# Class with inheritance
ast-grep --pattern 'class $CLASS < $BASE; $$$; end' -l rb

# Module definitions
ast-grep --pattern 'module $MODULE; $$$; end' -l rb
```

### Blocks and Iterators

```bash
# Blocks with do/end
ast-grep --pattern '$EXPR do |$PARAM|; $$$; end' -l rb

# Blocks with braces
ast-grep --pattern '$EXPR { |$PARAM| $$$ }' -l rb

# Each iterator
ast-grep --pattern '$COLLECTION.each do |$ITEM|; $$$; end' -l rb

# Map
ast-grep --pattern '$COLLECTION.map { |$ITEM| $$$ }' -l rb
```

### Rails Patterns

```bash
# Route definitions
ast-grep --pattern 'get "$PATH", to: "$HANDLER"' -l rb
ast-grep --pattern 'post "$PATH", to: "$HANDLER"' -l rb

# ActiveRecord queries
ast-grep --pattern '$MODEL.where($$$)' -l rb
ast-grep --pattern '$MODEL.find_by($$$)' -l rb

# Validations
ast-grep --pattern 'validates $$$' -l rb
```

---

## Advanced Usage

### Refactoring

```bash
# Rename function
ast-grep --pattern 'old_function($$$)' \
         --rewrite 'new_function($$$)' \
         -l py --interactive

# Update API version
ast-grep --pattern 'api.v1.$METHOD($$$)' \
         --rewrite 'api.v2.$METHOD($$$)' \
         -l py

# Modernize var to const
ast-grep --pattern 'var $VAR = $EXPR' \
         --rewrite 'const $VAR = $EXPR' \
         -l js --interactive

# Add type annotations
ast-grep --pattern 'def $FUNC($PARAM):' \
         --rewrite 'def $FUNC($PARAM: Any):' \
         -l py
```

### Multi-Pattern Search

```bash
# Search with multiple patterns (OR)
ast-grep --pattern 'print($$$)' -l py && \
ast-grep --pattern 'logging.$METHOD($$$)' -l py

# Chain searches (AND)
ast-grep --pattern 'def $FUNC($$$):' -l py | \
  grep -v test | \
  xargs -I {} ast-grep --pattern 'return $$$' {}
```

### Complex Patterns

```bash
# Find functions with many parameters (code smell)
ast-grep --pattern 'def $FUNC($A, $B, $C, $D, $E, $$$):' -l py

# Find deeply nested function calls
ast-grep --pattern '$A($B($C($$$)))' -l py

# Find unused variables (assigned but not used)
ast-grep --pattern '$VAR = $$$' -l py  # Then analyze

# Find mutable default arguments (Python anti-pattern)
ast-grep --pattern 'def $FUNC($PARAM=[]):' -l py
ast-grep --pattern 'def $FUNC($PARAM={}):' -l py
```

### Debugging Patterns

```bash
# Find console.log statements
ast-grep --pattern 'console.log($$$)' -l js

# Find debugger statements
ast-grep --pattern 'debugger' -l js

# Find print debugging
ast-grep --pattern 'print($$$)' -l py

# Find TODO comments in code (not comments, but in strings)
ast-grep --pattern '"TODO: $$$"' -l py
```

## Rule Files

Create reusable rules in YAML:

```yaml
# rules.yml
id: no-mutable-default
language: python
rule:
  pattern: 'def $FUNC($$$, $PARAM=[], $$$):'
message: Avoid mutable default arguments
severity: warning
```

Use with:
```bash
ast-grep scan --rule rules.yml
```

## Configuration

Create `.ast-grep.yml` in project root:

```yaml
ruleDirs:
  - rules
testDirs:
  - tests
ignore:
  - node_modules
  - .venv
  - dist
```

## Performance Tips

1. **Use language specification**: `-l py` is more accurate
2. **Narrow scope**: Search specific directories
3. **Use specific patterns**: More specific = faster
4. **Cache results**: Output to file for repeated analysis

## Interactive Workflows

```bash
# Find and select function to edit
ast-grep --pattern 'def $FUNC($$$):' -l py | \
  fzf --preview 'bat --color=always {1}' | \
  cut -d: -f1 | \
  xargs $EDITOR

# Find usages and refactor
ast-grep --pattern 'old_name($$$)' -l py | \
  fzf -m | \
  xargs ast-grep --pattern 'old_name($$$)' --rewrite 'new_name($$$)' --interactive
```

## Tips and Tricks

### Finding Security Issues

```bash
# SQL injection risks
ast-grep --pattern 'execute("$$$" + $VAR)' -l py

# XSS risks
ast-grep --pattern 'innerHTML = $$$' -l js

# Command injection
ast-grep --pattern 'os.system($$$)' -l py
```

### Code Quality Analysis

```bash
# Find long functions (structural complexity)
ast-grep --pattern 'def $FUNC($$$): $$$' -l py | \
  awk -F: '{print $1":"$2}' | \
  xargs -I {} sh -c 'echo {}; sed -n "{}p" | wc -l'

# Find classes with many methods
ast-grep --pattern 'class $CLASS: $$$' -l py

# Find deeply nested code
ast-grep --pattern 'if $A: if $B: if $C: $$$' -l py
```

### Documentation

```bash
# Find undocumented functions
ast-grep --pattern 'def $FUNC($$$):' -l py | \
  xargs rg -L '"""'  # Functions without docstrings

# Find public APIs
ast-grep --pattern 'export function $FUNC($$$) { $$$ }' -l ts
```

## Comparison with grep/rg

| Task | grep/rg | ast-grep |
|------|---------|----------|
| Find string "print" | `rg print` | N/A |
| Find print function calls | `rg 'print\('` (fragile) | `ast-grep --pattern 'print($$$)'` |
| Find function definitions | `rg '^def '` (limited) | `ast-grep --pattern 'def $F($$$):'` |
| Rename function | Complex sed | `--rewrite` flag |
| Find by structure | Not possible | Native |
