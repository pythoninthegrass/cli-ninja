# jq - JSON Processing Cookbook

## Overview

`jq` is a lightweight command-line JSON processor. It's like `sed` for JSON data.

## Basic Queries

### Identity and Pretty Print

```bash
# Identity (pretty print)
jq . file.json

# Compact output
jq -c . file.json

# Raw output (no quotes for strings)
jq -r . file.json

# Sort keys
jq -S . file.json
```

### Accessing Fields

```bash
# Top-level field
jq '.name' file.json

# Nested field
jq '.user.email' file.json

# Deeply nested
jq '.data.user.profile.settings.theme' file.json

# Optional fields (null if missing)
jq '.user.address?' file.json
```

### Array Access

```bash
# First element
jq '.[0]' file.json

# Last element
jq '.[-1]' file.json

# Specific index
jq '.[2]' file.json

# Slice (first 3 elements)
jq '.[:3]' file.json

# Slice (elements 2-5)
jq '.[2:5]' file.json

# All elements
jq '.[]' file.json
```

## Iterating

### Array Iteration

```bash
# Extract field from each element
jq '.users[].name' file.json

# Multiple fields
jq '.users[] | .name, .email' file.json

# Nested iteration
jq '.departments[].employees[].name' file.json
```

### Object Iteration

```bash
# All values
jq '.[]' file.json

# All keys
jq 'keys' file.json

# Key-value pairs
jq 'to_entries' file.json

# Iterate key-value
jq 'to_entries[] | .key + ": " + (.value | tostring)' file.json
```

## Filtering

### Select

```bash
# Filter by condition
jq '.users[] | select(.active == true)' file.json

# Multiple conditions (AND)
jq '.users[] | select(.active == true and .age > 18)' file.json

# Multiple conditions (OR)
jq '.users[] | select(.active == true or .admin == true)' file.json

# Not
jq '.users[] | select(.active != false)' file.json

# Check field exists
jq '.users[] | select(.email != null)' file.json
jq '.users[] | select(has("email"))' file.json
```

### Comparison Operators

```bash
# Equality
jq '.items[] | select(.status == "active")' file.json

# Greater/Less than
jq '.items[] | select(.price > 100)' file.json
jq '.items[] | select(.price <= 50)' file.json

# String contains
jq '.items[] | select(.name | contains("widget"))' file.json

# String starts with
jq '.items[] | select(.name | startswith("A"))' file.json

# String ends with
jq '.items[] | select(.name | endswith(".json"))' file.json

# Regex match
jq '.items[] | select(.email | test("@gmail\\.com$"))' file.json
```

## Transforming

### Map

```bash
# Extract single field
jq '.users | map(.name)' file.json

# Extract multiple fields
jq '.users | map({name, email})' file.json

# Transform values
jq '.prices | map(. * 1.1)' file.json

# Conditional transformation
jq '.users | map(if .active then .name else empty end)' file.json
```

### Reduce

```bash
# Sum
jq '[.items[].price] | add' file.json

# Average
jq '[.items[].price] | add / length' file.json

# Min/Max
jq '[.items[].price] | min' file.json
jq '[.items[].price] | max' file.json

# Count
jq '.items | length' file.json

# Custom reduce
jq 'reduce .items[] as $item (0; . + $item.price)' file.json
```

### Group By

```bash
# Group by field
jq 'group_by(.category)' file.json

# Group and count
jq 'group_by(.category) | map({category: .[0].category, count: length})' file.json

# Group and aggregate
jq 'group_by(.category) | map({
  category: .[0].category,
  total: map(.price) | add
})' file.json
```

## Sorting

```bash
# Sort array
jq 'sort' file.json

# Sort by field
jq 'sort_by(.name)' file.json

# Reverse sort
jq 'sort_by(.name) | reverse' file.json

# Sort by multiple fields
jq 'sort_by(.category, .name)' file.json

# Sort numbers
jq 'sort_by(.price | tonumber)' file.json
```

## Constructing

### Objects

```bash
# New object with specific fields
jq '{name: .name, email: .email}' file.json

# Rename fields
jq '{username: .name, mail: .email}' file.json

# Computed fields
jq '{
  name: .name,
  fullName: .firstName + " " + .lastName,
  discountPrice: .price * 0.9
}' file.json

# Nested objects
jq '{
  user: {
    name: .name,
    contact: {email: .email}
  }
}' file.json
```

### Arrays

```bash
# Create array from fields
jq '[.name, .email, .age]' file.json

# Array of objects
jq '[.users[] | {name, email}]' file.json

# Flatten nested arrays
jq '.departments[].employees | flatten' file.json

# Unique elements
jq '.tags | unique' file.json

# Array difference
jq '.a - .b' file.json
```

## String Operations

```bash
# Concatenation
jq '.firstName + " " + .lastName' file.json

# Interpolation
jq '"Hello, \(.name)!"' file.json

# String length
jq '.name | length' file.json

# Uppercase/Lowercase
jq '.name | ascii_upcase' file.json
jq '.name | ascii_downcase' file.json

# Split string
jq '.path | split("/")' file.json

# Join array
jq '.tags | join(", ")' file.json

# Trim whitespace
jq '.text | gsub("^\\s+|\\s+$"; "")' file.json

# Replace
jq '.text | gsub("old"; "new")' file.json
```

## Type Conversions

```bash
# To string
jq '.age | tostring' file.json

# To number
jq '.price | tonumber' file.json

# To array
jq '[.]' file.json

# Type check
jq '.value | type' file.json

# Type test
jq 'if .value | type == "string" then "is string" else "not string" end' file.json
```

## Conditionals

```bash
# If-then-else
jq 'if .active then "active" else "inactive" end' file.json

# Multiple conditions
jq 'if .score >= 90 then "A"
    elif .score >= 80 then "B"
    elif .score >= 70 then "C"
    else "F"
    end' file.json

# Ternary-like
jq '.users[] | {name, status: (if .active then "active" else "inactive" end)}' file.json

# Alternative operator
jq '.value // "default"' file.json  # Use "default" if .value is null/false
```

## Combining Data

### Merging

```bash
# Merge objects
jq '. + {newField: "value"}' file.json

# Merge arrays
jq '.a + .b' file.json

# Recursive merge
jq '. * {user: {active: true}}' file.json

# Merge multiple files
jq -s '.[0] + .[1]' file1.json file2.json
```

### Joining

```bash
# Array join
jq '.array1 + .array2' file.json

# Unique elements from multiple arrays
jq '(.array1 + .array2) | unique' file.json

# Intersection
jq '.array1 - (.array1 - .array2)' file.json
```

## Advanced Patterns

### Working with Nested Data

```bash
# Recursive descent
jq '.. | .name? // empty' file.json

# Find all values for a key
jq '.. | .email? // empty' file.json

# Flatten deeply nested structure
jq '[.. | .users? // empty] | flatten' file.json
```

### Multiple Outputs

```bash
# Multiple queries
jq '.name, .email' file.json

# Conditional multiple outputs
jq '.users[] | .name, (if .admin then "ADMIN" else empty end)' file.json
```

### Error Handling

```bash
# Try-catch
jq 'try .field catch "not found"' file.json

# Optional field access
jq '.user?.email?' file.json

# Default values
jq '.count // 0' file.json
```

### Custom Functions

```bash
# Define and use function
jq 'def double: . * 2; .values[] | double' file.json

# Function with parameters
jq 'def multiply(n): . * n; .values[] | multiply(3)' file.json

# Recursive function
jq 'def factorial: if . <= 1 then 1 else . * ((. - 1) | factorial) end; 5 | factorial'
```

## Practical Examples

### API Response Processing

```bash
# Extract IDs
curl -s 'https://api.example.com/users' | jq '.data[].id'

# Format for CSV
curl -s 'https://api.example.com/users' | \
  jq -r '.data[] | [.id, .name, .email] | @csv'

# Extract nested data
curl -s 'https://api.example.com/posts' | \
  jq '.posts[] | {
    id,
    title,
    author: .user.name,
    comments: .comments | length
  }'
```

### Configuration Management

```bash
# Update config value
jq '.database.host = "localhost"' config.json

# Add new field
jq '. + {newFeature: true}' config.json

# Remove field
jq 'del(.deprecated)' config.json

# Merge configs
jq -s '.[0] * .[1]' base.json override.json > merged.json
```

### Data Analysis

```bash
# Count by category
jq 'group_by(.category) | map({category: .[0].category, count: length})' data.json

# Top 10 by price
jq 'sort_by(.price) | reverse | .[:10]' data.json

# Statistics
jq '{
  total: length,
  avgPrice: (map(.price) | add / length),
  maxPrice: (map(.price) | max),
  minPrice: (map(.price) | min)
}' data.json
```

### Testing and Validation

```bash
# Check required fields
jq '.users[] | select(has("name") and has("email") | not)' data.json

# Validate email format
jq '.users[] | select(.email | test("^[^@]+@[^@]+$") | not)' data.json

# Find duplicates
jq 'group_by(.id) | map(select(length > 1))' data.json
```

### Log Processing

```bash
# Filter log level
jq 'select(.level == "error")' logs.json

# Extract error messages
jq 'select(.level == "error") | .message' logs.json

# Group errors by type
jq -s 'group_by(.error_type) | map({type: .[0].error_type, count: length})' logs.json

# Time range filter
jq 'select(.timestamp >= "2024-01-01" and .timestamp < "2024-02-01")' logs.json
```

## Output Formats

```bash
# Raw output (no quotes)
jq -r '.name' file.json

# Compact output
jq -c '.' file.json

# Tab-separated
jq -r '.[] | [.name, .age] | @tsv' file.json

# CSV
jq -r '.[] | [.name, .age, .email] | @csv' file.json

# URL encoding
jq -r '.params | @uri' file.json

# Base64 encoding
jq -r '.data | @base64' file.json

# HTML encoding
jq -r '.content | @html' file.json

# JSON output (default)
jq '.' file.json
```

## Command-Line Options

```bash
# Read from stdin
echo '{"name":"test"}' | jq .

# Multiple files
jq . file1.json file2.json

# Slurp (read all files into array)
jq -s . file1.json file2.json

# Null input (generate data)
jq -n '{name: "test", date: now}'

# Exit with status code
jq -e 'select(.status == "ok")' file.json

# Tab indentation
jq --tab . file.json

# No color
jq -M . file.json

# Color (force)
jq -C . file.json
```

## Tips and Tricks

### Debugging

```bash
# Pretty print
jq . file.json | less

# Inspect structure
jq 'paths' file.json

# Show all keys
jq '[paths | select(length == 1)] | unique' file.json

# Debug filter
jq 'debug | .name' file.json
```

### Performance

```bash
# Stream processing (memory efficient)
jq --stream . large.json

# Compact input
jq -c . file.json

# Limit output
jq 'limit(10; .items[])' file.json
```

### Combining with Other Tools

```bash
# With curl
curl -s 'https://api.github.com/users/github' | jq '.name'

# With fd/rg
fd -e json | xargs jq '.version'

# With fzf
jq -r '.users[].name' users.json | fzf

# With xargs
jq -r '.files[]' manifest.json | xargs cat
```

## Common Patterns

### Filter-Map-Reduce

```bash
# Classic pattern
jq '.items[] |           # iterate
    select(.active) |    # filter
    .price |             # map
    add'                 # reduce
```

### Pagination

```bash
# Page 1 (items 0-9)
jq '.items[0:10]' data.json

# Page 2 (items 10-19)
jq '.items[10:20]' data.json

# Function for pagination
page() {
  local page=$1
  local size=${2:-10}
  local start=$((page * size))
  local end=$((start + size))
  jq ".items[$start:$end]" data.json
}
```

### Data Migration

```bash
# Old format to new format
jq 'map({
  id: .user_id,
  profile: {
    name: .username,
    email: .user_email
  }
})' old_format.json > new_format.json
```

## Error Messages

```bash
# Common errors and fixes

# "parse error: Invalid numeric literal"
# → Check JSON syntax, trailing commas

# "Cannot iterate over null"
# → Add optional operator: .field[]?

# "Cannot index string with string"
# → Check data types, .field might be string not object

# "jq: error: syntax error"
# → Check quote escaping in shell
```
