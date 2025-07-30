# AI Agent Git Operations for Terraform Repositories

## Core Principles

**Simplicity First**: Each operation should have a single, clear purpose. Avoid complecting git operations with unrelated concerns.

**Composable Workflow**: Each stage builds independently on the previous, allowing for easy debugging and iteration.

## Branch Management

### Creating Branches
- **Format**: `feature/descriptive-name` or `fix/issue-description`
- **Source**: Always branch from `main`
- **Naming**: Use kebab-case, be specific about the change

```bash
git checkout main
git pull origin main
git checkout -b feature/add-vpc-module
```

### Keeping Branches Current
- **Method**: Rebase only (preserve linear history)
- **Frequency**: Daily, or before any major work session
- **Conflict Resolution**: Address conflicts immediately

```bash
git fetch origin
git rebase origin/main
```

## Pre-Commit Standards

### Code Formatting (Required)
```bash
terraform fmt -recursive
```

### Documentation Generation (Required)
```bash
# Run only at repository root - configured for recursive documentation
terraform-docs .
```

### Validation Pipeline (Required)
Execute in sequence - each step depends on the previous:

1. **Syntax Check**
   ```bash
   terraform init && terraform validate
   ```

2. **Linting**
   ```bash
   tflint --recursive
   ```

3. **Example Validation**
   ```bash
   # Run in each example directory
   for dir in examples/*/; do
     (cd "$dir" && terraform init && terraform validate)
   done
   ```

4. **Test Execution**
   ```bash
   cd test && go test -v ./...
   ```

## Commit Standards

### Message Format
Follow [Conventional Commits 1.0.0](https://www.conventionalcommits.org/):

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

### Examples
```
feat(vpc): add multi-az subnet configuration
fix(security-group): resolve circular dependency issue
docs(readme): update module usage examples
test(vpc): add integration test for NAT gateway
```

### Commit Scope
- **Atomic Changes**: One logical change per commit
- **Complete Units**: Each commit should leave the repository in a working state
- **Clear Intent**: Commit message should explain *why*, not just *what*

## Pull Request Workflow

### Pre-PR Validation
Ensure all pre-commit checks pass:
```bash
# Complete validation pipeline
make validate  # or equivalent command sequence
```

### PR Requirements
1. **Title**: Must follow Conventional Commits format
2. **Description**: Complete all GitHub template sections
3. **Scope**: Single concern per PR (avoid complecting multiple features)
4. **Size**: Prefer smaller, focused PRs over large, complex ones

### PR Template Sections (All Required)
- [ ] **Summary**: What does this PR accomplish?
- [ ] **Changes**: Specific modifications made
- [ ] **Testing**: How was this validated?
- [ ] **Breaking Changes**: Any backwards compatibility concerns?
- [ ] **Documentation**: What docs were updated?

## Quality Gates

### Automated Checks (Must Pass)
- Terraform formatting
- Terraform validation
- TFLint compliance
- All tests passing
- Documentation generation

### Manual Review Focus
- **Simplicity**: Is the solution as simple as possible?
- **Composition**: Are components properly decoupled?
- **Clarity**: Is the intent obvious from the code?
- **Testability**: Can changes be easily validated?

## Troubleshooting

### Common Issues
1. **Rebase Conflicts**: Resolve immediately, don't accumulate
2. **Test Failures**: Fix root cause, don't mask symptoms
3. **Lint Errors**: Address policy violations, don't suppress

### Recovery Patterns
```bash
# Reset to clean state if needed
git reset --hard origin/main

# Clean workspace
git clean -fd

```

## Notes for AI Agents

- **Fail Fast**: Stop pipeline on first error
- **Context Preservation**: Maintain clear audit trail of operations
- **Rollback Strategy**: Always know how to undo changes
- **Validation Order**: Run cheap checks first (fmt, lint) before expensive ones (tests)
