# yq - YAML/XML Processing Examples

## Overview

`yq` is a lightweight command-line YAML/XML processor. It's like `jq` but for YAML and XML.

## YAML Processing

### Basic Queries

```bash
# Pretty print
yq . file.yaml

# Access field
yq '.name' file.yaml

# Nested access
yq '.database.host' file.yaml

# Array access
yq '.items[0]' file.yaml

# All array elements
yq '.items[]' file.yaml
```

### Filtering

```bash
# Filter by condition
yq '.users[] | select(.active == true)' file.yaml

# Multiple conditions
yq '.users[] | select(.age > 18 and .active == true)' file.yaml

# String contains
yq '.items[] | select(.name | contains("widget"))' file.yaml
```

### Transforming

```bash
# Extract specific fields
yq '.users[] | {name, email}' file.yaml

# Map array
yq '.items | map(.price * 1.1)' file.yaml

# Sort
yq 'sort_by(.name)' file.yaml

# Group by
yq 'group_by(.category)' file.yaml
```

### Updating Values

```bash
# Update single field
yq '.database.host = "localhost"' file.yaml

# Update nested field
yq '.server.config.port = 8080' file.yaml

# Update array element
yq '.items[0].price = 99.99' file.yaml

# Add new field
yq '. + {"newField": "value"}' file.yaml

# Delete field
yq 'del(.deprecated)' file.yaml
```

### In-Place Editing

```bash
# Edit file in-place
yq -i '.version = "2.0"' file.yaml

# Multiple updates
yq -i '
  .version = "2.0" |
  .updated = now |
  .deprecated = null
' file.yaml
```

### Merging Files

```bash
# Merge two YAML files
yq '. *= load("other.yaml")' base.yaml

# Merge with override
yq 'load("base.yaml") * load("override.yaml")'

# Merge multiple files
yq eval-all '. as $item ireduce ({}; . * $item)' file1.yaml file2.yaml file3.yaml
```

## Format Conversion

### YAML to JSON

```bash
# Convert YAML to JSON
yq -o json . file.yaml

# Compact JSON
yq -o json -I 0 . file.yaml

# Pretty JSON
yq -o json . file.yaml | jq .
```

### JSON to YAML

```bash
# Convert JSON to YAML
yq -P . file.json

# From stdin
echo '{"name":"test"}' | yq -P .

# Pipeline
cat file.json | yq -P . > file.yaml
```

### YAML to TOML

```bash
# Convert YAML to TOML
yq -o toml . file.yaml
```

### YAML to XML

```bash
# Convert YAML to XML
yq -o xml . file.yaml
```

## XML Processing

### Reading XML

```bash
# Parse XML
yq -p xml . file.xml

# Access element
yq -p xml '.root.element' file.xml

# Access attribute
yq -p xml '.root.+@attr' file.xml

# All elements
yq -p xml '.root.items[]' file.xml
```

### Filtering XML

```bash
# Filter by attribute
yq -p xml '.root.item[] | select(.+@id == "123")' file.xml

# Filter by element value
yq -p xml '.root.item[] | select(.name == "test")' file.xml
```

### XML to JSON

```bash
# Convert XML to JSON
yq -p xml -o json . file.xml

# Extract and convert
yq -p xml -o json '.root.items' file.xml
```

### XML to YAML

```bash
# Convert XML to YAML
yq -p xml . file.xml

# Pretty print
yq -p xml -P . file.xml
```

## Common Use Cases

### Docker Compose

```bash
# Get service names
yq '.services | keys' docker-compose.yml

# Get image for service
yq '.services.web.image' docker-compose.yml

# Update service port
yq -i '.services.web.ports[0] = "8080:80"' docker-compose.yml

# Add environment variable
yq -i '.services.web.environment.DEBUG = "true"' docker-compose.yml

# Get all exposed ports
yq '.services[].ports[]' docker-compose.yml
```

### Kubernetes

```bash
# Get pod name
yq '.metadata.name' pod.yaml

# Get container image
yq '.spec.containers[0].image' pod.yaml

# Update replicas
yq -i '.spec.replicas = 3' deployment.yaml

# Get all container names
yq '.spec.template.spec.containers[].name' deployment.yaml

# Get resource limits
yq '.spec.template.spec.containers[0].resources.limits' deployment.yaml
```

### CI/CD (GitHub Actions, GitLab CI)

```bash
# Get job names
yq '.jobs | keys' .github/workflows/ci.yml

# Get steps for job
yq '.jobs.build.steps[].name' .github/workflows/ci.yml

# Update trigger
yq -i '.on.push.branches = ["main", "develop"]' .github/workflows/ci.yml

# Get all used actions
yq '.jobs[].steps[].uses' .github/workflows/ci.yml
```

### Configuration Files

```bash
# Application config
yq '.app.port' config.yaml
yq '.database.connection.host' config.yaml

# Update config
yq -i '.app.debug = true' config.yaml
yq -i '.cache.enabled = false' config.yaml

# Merge configs
yq '. *= load("config.local.yaml")' config.yaml
```

### Ansible

```bash
# Get hosts
yq '.all.hosts | keys' inventory.yaml

# Get variables
yq '.all.vars' inventory.yaml

# Update host variable
yq -i '.all.hosts.server1.ansible_host = "192.168.1.10"' inventory.yaml

# Get all playbook tasks
yq '.[] | select(.tasks) | .tasks[].name' playbook.yaml
```

## Advanced Patterns

### Conditional Updates

```bash
# Update if exists
yq '(select(.field) | .field) = "new-value"' file.yaml

# Update based on condition
yq '(.items[] | select(.price > 100) | .discount) = 0.2' file.yaml

# Add field if missing
yq '. + (if has("field") then {} else {"field": "default"} end)' file.yaml
```

### Complex Transformations

```bash
# Restructure data
yq '.users | map({
  username: .name,
  contact: {
    email: .email,
    phone: .phone
  }
})' file.yaml

# Aggregate data
yq '.items | group_by(.category) | map({
  category: .[0].category,
  total: map(.price) | add
})' file.yaml

# Pivot data
yq 'reduce .items[] as $item ({}; .[$item.name] = $item.value)' file.yaml
```

### Working with Arrays

```bash
# Append to array
yq '.items += ["new-item"]' file.yaml

# Prepend to array
yq '.items = ["new-item"] + .items' file.yaml

# Remove from array
yq 'del(.items[2])' file.yaml

# Filter array
yq '.items = [.items[] | select(.active == true)]' file.yaml

# Unique array
yq '.items | unique' file.yaml

# Flatten array
yq '.items | flatten' file.yaml
```

### Multi-Document YAML

```bash
# Process all documents
yq '.' multi-doc.yaml

# Select specific document
yq 'select(document_index == 0)' multi-doc.yaml

# Filter documents
yq 'select(.kind == "Deployment")' multi-doc.yaml

# Update all documents
yq -i '.metadata.labels.app = "myapp"' multi-doc.yaml
```

## String Operations

```bash
# Concatenation
yq '.fullName = .firstName + " " + .lastName' file.yaml

# Interpolation
yq '.message = "Hello, " + .name + "!"' file.yaml

# Uppercase
yq '.name | upcase' file.yaml

# Lowercase
yq '.name | downcase' file.yaml

# Split
yq '.path | split("/")' file.yaml

# Join
yq '.items | join(", ")' file.yaml

# Replace
yq '.text | sub("old", "new")' file.yaml

# Trim
yq '.text | trim' file.yaml
```

## Type Checking and Conversion

```bash
# Check type
yq '.field | type' file.yaml

# Convert to string
yq '.number | tostring' file.yaml

# Convert to number
yq '.string | tonumber' file.yaml

# Check if exists
yq 'has("field")' file.yaml

# Length
yq '.items | length' file.yaml
```

## Comments

```bash
# Preserve comments (default behavior)
yq '.field = "new-value"' file.yaml

# Add headComment
yq '.field headComment="This is a comment"' file.yaml

# Add lineComment
yq '.field lineComment="inline comment"' file.yaml

# Add footComment
yq '.field footComment="bottom comment"' file.yaml
```

## Anchors and Aliases

```bash
# Create anchor
yq '.base.&anchor = {"key": "value"}' file.yaml

# Reference anchor
yq '.other = .base.*anchor' file.yaml

# Merge anchors
yq '.combined = .base.*anchor * .override' file.yaml
```

## Validation

```bash
# Check if valid YAML
yq . file.yaml > /dev/null && echo "Valid" || echo "Invalid"

# Validate schema (requires schema file)
yq 'load("schema.yaml") | . as $schema | load("data.yaml") | validate($schema)'

# Check required fields
yq 'select(has("requiredField") | not)' file.yaml

# Validate format
yq 'select(.email | test("^[^@]+@[^@]+$") | not)' file.yaml
```

## Output Formatting

```bash
# Default YAML output
yq . file.yaml

# Compact (minimal whitespace)
yq -I 0 . file.yaml

# Custom indentation (4 spaces)
yq -I 4 . file.yaml

# No colors
yq -C 0 . file.yaml

# Force colors
yq -C 1 . file.yaml

# Raw output (no quotes)
yq -r '.name' file.yaml

# One line per document
yq -o json . multi-doc.yaml
```

## Scripting Examples

### Environment-Specific Configs

```bash
#!/bin/bash
ENV=${1:-dev}

yq ". *= load(\"config.$ENV.yaml\")" config.base.yaml > config.yaml
```

### Bulk Updates

```bash
#!/bin/bash
for file in *.yaml; do
  yq -i '.metadata.labels.version = "2.0"' "$file"
done
```

### Config Validation

```bash
#!/bin/bash
REQUIRED_FIELDS=("name" "version" "description")

for field in "${REQUIRED_FIELDS[@]}"; do
  if ! yq -e "has(\"$field\")" config.yaml > /dev/null; then
    echo "Missing required field: $field"
    exit 1
  fi
done
```

### Secret Management

```bash
#!/bin/bash
# Extract secrets from YAML
yq '.secrets' config.yaml > secrets.yaml

# Encrypt secrets (example with age)
yq '.secrets' config.yaml | age -e -o secrets.age

# Decrypt and merge
age -d secrets.age | yq -P . > secrets.yaml
yq '. *= load("secrets.yaml")' config.yaml
```

## Integration Examples

### With Git

```bash
# Pre-commit hook to sort keys
git diff --cached --name-only | \
  grep '\.yaml$' | \
  xargs -I {} yq -i -P 'sort_keys(..)' {}
```

### With Docker

```bash
# Extract image tags
yq '.services[].image' docker-compose.yml | \
  cut -d: -f2 | \
  sort -u

# Update all images to latest
yq -i '(.services[].image) |= sub(":.*", ":latest")' docker-compose.yml
```

### With Kubernetes

```bash
# Apply with modifications
yq '.spec.replicas = 3' deployment.yaml | kubectl apply -f -

# Extract all images
kubectl get pods -o yaml | \
  yq '.items[].spec.containers[].image' | \
  sort -u

# Generate manifests
yq eval-all '. as $item ireduce ({}; . * $item)' \
  base/*.yaml overlays/prod/*.yaml | \
  kubectl apply -f -
```

### With CI/CD

```bash
# Update version in workflow
VERSION=$(git describe --tags)
yq -i ".env.VERSION = \"$VERSION\"" .github/workflows/deploy.yml

# Extract job matrix
MATRIX=$(yq -o json '.jobs.test.strategy.matrix' .github/workflows/ci.yml)
echo "matrix=$MATRIX" >> $GITHUB_OUTPUT
```

## Performance Tips

1. **Use in-place editing**: `-i` avoids reading/writing twice
2. **Pipe instead of temp files**: More efficient for transformations
3. **Specific paths**: Access `.field.subfield` instead of iterating
4. **Limit output**: Use `select` early to filter data
5. **Batch operations**: Combine multiple updates in one command

## Common Patterns

### Configuration Merging

```bash
# Base + environment + local
yq eval-all '. as $item ireduce ({}; . * $item)' \
  config.base.yaml \
  config.$ENV.yaml \
  config.local.yaml
```

### Secret Injection

```bash
# Replace placeholders with actual values
yq '(.. | select(tag == "!!str")) |= envsubst' config.yaml
```

### Manifest Generation

```bash
# Generate K8s manifests from template
yq '(.metadata.name) = "app-" + env(ENV) |
    (.spec.replicas) = env(REPLICAS) |
    (.spec.template.spec.containers[0].image) = env(IMAGE)' \
  template.yaml
```

## Tips and Tricks

### Debugging

```bash
# Pretty print to see structure
yq -P . file.yaml

# Show paths
yq '.. | path | join(".")' file.yaml

# Find all keys
yq '.. | select(tag == "!!map") | keys' file.yaml
```

### Working with Large Files

```bash
# Stream processing
yq -N . large.yaml  # Process without loading entirely

# Extract specific document
yq 'select(document_index == 5)' large-multi-doc.yaml

# Count documents
yq -N '.' multi-doc.yaml | grep -c '^---$'
```

### Shell Aliases

```bash
alias yqp='yq -P'           # Pretty print
alias yqj='yq -o json'      # To JSON
alias yqs='yq -I 2'         # 2-space indent
alias yqc='yq -C 1'         # Force colors
```

## Error Handling

```bash
# Check if file exists and is valid
if yq . file.yaml &>/dev/null; then
  echo "Valid YAML"
else
  echo "Invalid YAML or file not found"
  exit 1
fi

# Try with fallback
VALUE=$(yq '.field // "default"' file.yaml)

# Conditional processing
if yq -e '.enabled == true' config.yaml > /dev/null; then
  # Process when enabled
  yq '.items[]' config.yaml
fi
```

## Comparison with Other Tools

| Task | yq | jq (JSON) | sed/awk |
|------|----|-----------| --------|
| Parse YAML | Native | Need conversion | Complex |
| Parse JSON | Can do | Native | Possible |
| Update in-place | `-i` flag | Needs sponge | `-i` flag |
| Preserve comments | Yes | N/A | Yes |
| Type safety | Yes | Yes | No |
| Learning curve | Medium | Medium | Low/High |
