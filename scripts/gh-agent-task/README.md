# gh-agent-task

GitHub CLI extension for managing AI agent tasks in the Ollama project.

## Overview

This extension provides commands to view, list, and manage agent tasks that run as part of GitHub workflows or CI/CD pipelines.

## Installation

### Install from Local Path (Development)

```bash
gh extension install /path/to/ollama/scripts/gh-agent-task
```

### Install from GitHub (Once Published)

```bash
gh extension install ollama/gh-agent-task
```

## Usage

### View Task Details

View basic information about a task:

```bash
gh agent-task view dd1fee47-abb8-4a9c-b18e-60b512427f5f
```

View task with execution logs:

```bash
gh agent-task view dd1fee47-abb8-4a9c-b18e-60b512427f5f --log
```

View task in JSON format:

```bash
gh agent-task view dd1fee47-abb8-4a9c-b18e-60b512427f5f --json
```

### List All Tasks

```bash
gh agent-task list
```

### View Task Logs Only

```bash
gh agent-task logs dd1fee47-abb8-4a9c-b18e-60b512427f5f
```

## Commands

- **view** - View details of a specific agent task
- **list** - List all agent tasks for the current repository
- **logs** - View execution logs for a specific task
- **version** - Show extension version

## Task ID Format

Task IDs are UUIDs in the format: `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`

Example: `dd1fee47-abb8-4a9c-b18e-60b512427f5f`

## Implementation Notes

### Current State

This is a **prototype implementation** with mock data. The current version:

- ✅ Provides a complete CLI interface
- ✅ Validates UUID format
- ✅ Supports all planned commands
- ⚠️ Uses mock data for demonstration

### Integration Points

To make this functional, you need to implement:

1. **Task Storage Backend**
   - Store task metadata in GitHub Issues with labels
   - Use GitHub Projects for tracking
   - Store in GitHub Actions artifacts
   - Use a custom API backend

2. **Log Storage**
   - GitHub Actions logs
   - Custom log aggregation service
   - Artifact uploads

3. **API Integration**
   - GitHub REST API for workflow runs
   - GitHub GraphQL API for complex queries
   - Custom backend API

### Recommended Architecture

```
┌─────────────────┐
│  gh agent-task  │
└────────┬────────┘
         │
    ┌────┴────────────────────┐
    │                         │
┌───▼────────┐       ┌────────▼──────┐
│ GitHub API │       │  Task Storage │
│ (Workflows)│       │  (Issues/API) │
└────────────┘       └───────────────┘
```

## Examples

### Example: View Task

```bash
$ gh agent-task view dd1fee47-abb8-4a9c-b18e-60b512427f5f

Fetching task dd1fee47-abb8-4a9c-b18e-60b512427f5f from ollama/ollama...

Task Details
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ID:          dd1fee47-abb8-4a9c-b18e-60b512427f5f
Status:      completed
Agent:       my-agent
Model:       claude-3.5-sonnet
Description: Review pull request changes
Result:      success
Created:     2024-01-23T08:26:00Z
Exec Time:   42s
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Example: View with Logs

```bash
$ gh agent-task view dd1fee47-abb8-4a9c-b18e-60b512427f5f --log

Fetching task dd1fee47-abb8-4a9c-b18e-60b512427f5f from ollama/ollama...

Task Details
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ID:          dd1fee47-abb8-4a9c-b18e-60b512427f5f
Status:      completed
Agent:       my-agent
Model:       claude-3.5-sonnet
Description: Review pull request changes
Result:      success
Created:     2024-01-23T08:26:00Z
Exec Time:   42s
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Task Logs
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
2024-01-23 08:26:00 | INFO  | Task started
2024-01-23 08:26:01 | INFO  | Loading agent configuration: my-agent
2024-01-23 08:26:02 | INFO  | Initializing model: claude-3.5-sonnet
2024-01-23 08:26:05 | INFO  | Analyzing pull request changes
2024-01-23 08:26:10 | INFO  | Found 5 files changed
2024-01-23 08:26:15 | INFO  | Running code review analysis
2024-01-23 08:26:30 | INFO  | Generated 3 review comments
2024-01-23 08:26:35 | INFO  | Posting review to GitHub
2024-01-23 08:26:40 | INFO  | Task completed successfully
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Development

### Testing Locally

```bash
# Make the script executable
chmod +x gh-agent-task

# Test directly
./gh-agent-task --help
./gh-agent-task view dd1fee47-abb8-4a9c-b18e-60b512427f5f
./gh-agent-task view dd1fee47-abb8-4a9c-b18e-60b512427f5f --log
```

### Installing for Testing

```bash
# Install from local path
gh extension install .

# Test as gh extension
gh agent-task --help
gh agent-task view dd1fee47-abb8-4a9c-b18e-60b512427f5f --log
```

## Contributing

See [CONTRIBUTING.md](../../CONTRIBUTING.md) for guidelines.

## License

See [LICENSE](../../LICENSE) for details.
