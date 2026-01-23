# Implementation Guide for gh-agent-task

This guide explains how to transform the prototype `gh-agent-task` extension into a fully functional tool integrated with real data sources.

## Table of Contents

1. [Overview](#overview)
2. [Architecture Options](#architecture-options)
3. [Integration Approaches](#integration-approaches)
4. [Implementation Steps](#implementation-steps)
5. [API Design](#api-design)
6. [Storage Options](#storage-options)
7. [Security Considerations](#security-considerations)

## Overview

The `gh-agent-task` extension is currently a prototype with mock data. To make it production-ready, you need to integrate it with actual task storage and execution systems.

## Architecture Options

### Option 1: GitHub Actions Integration

Store task data in GitHub Actions workflow runs and artifacts.

**Pros:**
- Native GitHub integration
- No additional infrastructure
- Free for public repos
- Built-in authentication

**Cons:**
- Limited to 90-day retention
- Artifact size limits (500MB)
- Requires workflow runs

**Best for:** Projects already using GitHub Actions heavily

### Option 2: GitHub Issues + Labels

Store task metadata as GitHub Issues with specific labels.

**Pros:**
- Simple to implement
- Good UI for viewing tasks
- No additional infrastructure
- Permanent storage

**Cons:**
- Issue noise in repository
- Limited query capabilities
- Rate limits on GitHub API

**Best for:** Small to medium projects with manageable task volume

### Option 3: GitHub GraphQL API + Projects

Use GitHub Projects v2 for task management.

**Pros:**
- Rich query capabilities
- Better organization
- Native GitHub integration
- Custom fields support

**Cons:**
- More complex API
- Requires GraphQL knowledge
- Rate limits

**Best for:** Teams using GitHub Projects already

### Option 4: Custom Backend API

Build a dedicated backend service for task management.

**Pros:**
- Full control
- No rate limits
- Advanced features
- Best scalability

**Cons:**
- Infrastructure costs
- Maintenance overhead
- Authentication complexity

**Best for:** Enterprise deployments, high-volume usage

## Integration Approaches

### Approach 1: GitHub Actions Artifacts (Recommended for Prototyping)

Store task data as JSON in workflow artifacts.

#### Implementation

```bash
# In your workflow file (.github/workflows/agent-task.yml)
name: Agent Task Execution

on:
  workflow_dispatch:
    inputs:
      task_id:
        description: 'Task UUID'
        required: true
      agent:
        description: 'Agent to use'
        required: true

jobs:
  execute-task:
    runs-on: ubuntu-latest
    steps:
      - name: Generate Task Data
        id: task
        run: |
          cat > task-${GITHUB_RUN_ID}.json << EOF
          {
            "id": "${{ github.event.inputs.task_id }}",
            "status": "running",
            "created_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
            "repository": "${{ github.repository }}",
            "agent": "${{ github.event.inputs.agent }}",
            "workflow_run_id": "${GITHUB_RUN_ID}"
          }
          EOF
      
      - name: Upload Task Metadata
        uses: actions/upload-artifact@v3
        with:
          name: task-${{ github.event.inputs.task_id }}
          path: task-${GITHUB_RUN_ID}.json
      
      - name: Execute Agent Task
        run: |
          # Your agent execution logic here
          echo "Executing agent task..."
      
      - name: Upload Task Logs
        if: always()
        uses: actions/upload-artifact@v3
        with:
          name: task-${{ github.event.inputs.task_id }}-logs
          path: logs/
```

#### Modify `fetch_task_data` function

```bash
fetch_task_data() {
    local repo=$1
    local task_id=$2
    
    # Search for workflow runs with the task ID
    local runs=$(gh run list \
        --repo "$repo" \
        --json databaseId,name,conclusion,createdAt \
        --jq ".[] | select(.name | contains(\"$task_id\"))")
    
    if [[ -z "$runs" ]]; then
        return 1
    fi
    
    # Get the latest run
    local run_id=$(echo "$runs" | jq -r '.[0].databaseId')
    
    # Download artifact
    gh run download "$run_id" \
        --repo "$repo" \
        --name "task-$task_id" \
        --dir /tmp/
    
    # Read task data
    cat "/tmp/task-$task_id/task-*.json"
}
```

### Approach 2: GitHub Issues Backend

Use GitHub Issues as a database with labels for task tracking.

#### Create Task Issue

```bash
# Create a new task
create_task() {
    local agent=$1
    local description=$2
    local task_id=$(uuidgen)
    
    gh issue create \
        --repo "$REPO" \
        --title "Agent Task: $task_id" \
        --body "$(cat <<EOF
Agent: $agent
Task ID: $task_id
Description: $description
Status: pending
Created: $(date -u +%Y-%m-%dT%H:%M:%SZ)
EOF
)" \
        --label "agent-task" \
        --label "agent:$agent" \
        --label "status:pending"
    
    echo "$task_id"
}
```

#### Modify `fetch_task_data` function

```bash
fetch_task_data() {
    local repo=$1
    local task_id=$2
    
    # Search for issue with task ID
    local issue=$(gh issue list \
        --repo "$repo" \
        --label "agent-task" \
        --search "$task_id" \
        --json number,title,body,labels,createdAt,updatedAt \
        --limit 1)
    
    if [[ -z "$issue" ]] || [[ "$issue" == "[]" ]]; then
        return 1
    fi
    
    # Parse issue data and format as task JSON
    echo "$issue" | jq '.[0] | {
        id: (.body | match("Task ID: ([a-f0-9-]+)").captures[0].string),
        status: (.labels[] | select(.name | startswith("status:")) | .name | sub("status:"; "")),
        agent: (.labels[] | select(.name | startswith("agent:")) | .name | sub("agent:"; "")),
        created_at: .createdAt,
        updated_at: .updatedAt,
        repository: $repo,
        description: (.body | match("Description: (.+)").captures[0].string)
    }' --arg repo "$repo"
}
```

### Approach 3: Custom Backend API

Build a REST API for task management.

#### API Endpoints

```
GET  /api/tasks              - List all tasks
POST /api/tasks              - Create a new task
GET  /api/tasks/:id          - Get task details
GET  /api/tasks/:id/logs     - Get task logs
PUT  /api/tasks/:id          - Update task status
DELETE /api/tasks/:id        - Cancel/delete task
```

#### Modify `fetch_task_data` function

```bash
# Configuration
API_BASE_URL="${AGENT_TASK_API_URL:-https://api.example.com}"
API_TOKEN="${AGENT_TASK_API_TOKEN}"

fetch_task_data() {
    local repo=$1
    local task_id=$2
    
    # Call API endpoint
    curl -s \
        -H "Authorization: Bearer $API_TOKEN" \
        -H "Accept: application/json" \
        "$API_BASE_URL/api/tasks/$task_id?repo=$repo"
}

fetch_task_logs() {
    local task_id=$1
    
    curl -s \
        -H "Authorization: Bearer $API_TOKEN" \
        -H "Accept: application/json" \
        "$API_BASE_URL/api/tasks/$task_id/logs"
}
```

## Implementation Steps

### Step 1: Choose Your Architecture

1. Assess your requirements:
   - Task volume (how many tasks per day?)
   - Retention needs (how long to keep tasks?)
   - Query complexity (advanced filtering?)
   - Team size and access patterns
   - Infrastructure constraints

2. Select the appropriate architecture from the options above

### Step 2: Set Up Storage

#### For GitHub Actions:
```bash
# Create workflow file
mkdir -p .github/workflows
# Add agent-task.yml (see example above)
```

#### For GitHub Issues:
```bash
# Create labels
gh label create "agent-task" --color "0366d6" --description "Agent task tracking"
gh label create "status:pending" --color "fbca04"
gh label create "status:running" --color "0e8a16"
gh label create "status:completed" --color "0e8a16"
gh label create "status:failed" --color "d73a4a"
```

#### For Custom Backend:
```bash
# Deploy your API service
# Set environment variables
export AGENT_TASK_API_URL="https://your-api.example.com"
export AGENT_TASK_API_TOKEN="your-api-token"
```

### Step 3: Implement Data Fetching

Replace the mock `fetch_task_data()` function with one of the implementations above.

### Step 4: Implement Log Retrieval

Replace the mock `display_task_logs()` function:

```bash
display_task_logs() {
    local task_id=$1
    
    # For GitHub Actions
    local run_id=$(get_run_id_for_task "$task_id")
    gh run view "$run_id" --log
    
    # For Custom API
    # curl "$API_BASE_URL/api/tasks/$task_id/logs"
}
```

### Step 5: Add Task Creation

Implement a `create` command:

```bash
cmd_create() {
    local agent=$1
    local description=$2
    
    # Generate UUID
    local task_id=$(uuidgen | tr '[:upper:]' '[:lower:]')
    
    # Create task based on your architecture
    # - Trigger GitHub Actions workflow
    # - Create GitHub Issue
    # - POST to custom API
    
    success "Created task: $task_id"
    echo "$task_id"
}
```

### Step 6: Add Task Cancellation

Implement a `cancel` command:

```bash
cmd_cancel() {
    local task_id=$1
    
    # Cancel based on your architecture
    # - Cancel GitHub Actions run
    # - Close GitHub Issue
    # - DELETE/PUT to custom API
}
```

### Step 7: Test End-to-End

```bash
# Create a task
TASK_ID=$(gh agent-task create my-agent "Review PR #123")

# View the task
gh agent-task view "$TASK_ID"

# View with logs
gh agent-task view "$TASK_ID" --log

# List all tasks
gh agent-task list
```

## API Design

### Task Data Structure

```json
{
  "id": "dd1fee47-abb8-4a9c-b18e-60b512427f5f",
  "status": "completed|running|failed|pending|cancelled",
  "created_at": "2024-01-23T08:26:00Z",
  "updated_at": "2024-01-23T08:26:42Z",
  "started_at": "2024-01-23T08:26:01Z",
  "completed_at": "2024-01-23T08:26:42Z",
  "repository": "ollama/ollama",
  "agent": "my-agent",
  "task_type": "code-review|test|deploy|custom",
  "model": "claude-3.5-sonnet",
  "description": "Review pull request changes",
  "result": "success|failure|cancelled",
  "execution_time_seconds": 42,
  "metadata": {
    "pr_number": 123,
    "branch": "feature/new-feature",
    "triggered_by": "user@example.com"
  },
  "logs_url": "https://...",
  "artifacts": [
    {
      "name": "review-comments.md",
      "url": "https://..."
    }
  ]
}
```

### Log Entry Structure

```json
{
  "timestamp": "2024-01-23T08:26:00Z",
  "level": "INFO|WARNING|ERROR",
  "message": "Task started",
  "component": "agent-runner",
  "metadata": {}
}
```

## Storage Options

### Database Options

1. **PostgreSQL** - Best for custom backend with complex queries
2. **SQLite** - Good for small deployments or local testing
3. **Redis** - For caching and real-time updates
4. **DynamoDB** - For serverless deployments on AWS
5. **Firestore** - For serverless on Google Cloud

### File Storage

1. **GitHub Actions Artifacts** - Built-in, 90-day retention
2. **S3/Cloud Storage** - For logs and artifacts
3. **GitHub Releases** - For permanent artifacts

## Security Considerations

### Authentication

1. **GitHub Token**: Use `gh auth token` for GitHub API access
2. **API Keys**: Store in environment variables, never in code
3. **OAuth**: For user-specific actions

### Authorization

1. Verify user has repo access before showing task data
2. Implement role-based access control (RBAC)
3. Audit log access to sensitive task data

### Data Protection

1. Encrypt sensitive data in artifacts
2. Use HTTPS for all API calls
3. Implement rate limiting
4. Sanitize log output to prevent secret leakage

### Best Practices

```bash
# Check authentication
check_auth() {
    if ! gh auth status &>/dev/null; then
        error "Not authenticated with GitHub. Run: gh auth login"
    fi
}

# Verify repository access
verify_repo_access() {
    local repo=$1
    if ! gh repo view "$repo" &>/dev/null; then
        error "No access to repository: $repo"
    fi
}

# Sanitize output
sanitize_log() {
    sed -E 's/(token|password|secret)[=:][^ ]+/\1=***REDACTED***/gi'
}
```

## Next Steps

1. Choose your architecture
2. Implement data fetching
3. Add log retrieval
4. Test with real data
5. Add task creation/cancellation
6. Document for your team
7. Consider publishing as a GitHub extension

## Example: Full GitHub Actions Integration

See `examples/github-actions-integration.md` for a complete example of integrating with GitHub Actions workflows.

## Support

For questions or issues:
- Open an issue in the Ollama repository
- Join the Ollama Discord community
- Check the GitHub CLI extension documentation

## License

This extension is part of the Ollama project and follows the same license terms.
