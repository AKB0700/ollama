# GitHub Actions Integration Example

This example shows how to integrate `gh-agent-task` with GitHub Actions workflows to track real agent tasks.

## Overview

This integration:
1. Creates a GitHub Actions workflow that executes agent tasks
2. Stores task metadata and logs as artifacts
3. Allows querying task status via `gh agent-task view`

## Setup

### Step 1: Create the Agent Task Workflow

Create `.github/workflows/agent-task.yml` in your repository with the complete workflow configuration.

See the full workflow example in this directory.

### Step 2: Create Task Launcher Script

Create `scripts/launch-agent-task.sh` to easily launch new tasks.

### Step 3: Update gh-agent-task

Update the `fetch_task_data` and `display_task_logs` functions to query GitHub Actions artifacts.

## Usage

```bash
# Launch a task
./scripts/launch-agent-task.sh my-agent code-review "Review PR 123" 123

# View task
gh agent-task view <task-id>

# View with logs
gh agent-task view <task-id> --log
```

See the full documentation in this directory for complete implementation details.
