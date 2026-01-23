# Quick Start Guide

Get started with `gh-agent-task` in under 5 minutes!

## Installation

### Option 1: Use Directly (No Installation)

```bash
cd /home/runner/work/ollama/ollama
./scripts/gh-agent-task/gh-agent-task --help
```

### Option 2: Install as GitHub CLI Extension

```bash
gh extension install /home/runner/work/ollama/ollama/scripts/gh-agent-task
gh agent-task --help
```

## Basic Usage

### View a Task

```bash
gh agent-task view dd1fee47-abb8-4a9c-b18e-60b512427f5f
```

### View Task with Logs

```bash
gh agent-task view dd1fee47-abb8-4a9c-b18e-60b512427f5f --log
```

### List All Tasks

```bash
gh agent-task list
```

### JSON Output (for scripting)

```bash
gh agent-task view dd1fee47-abb8-4a9c-b18e-60b512427f5f --json | jq .
```

## Try the Demo

```bash
cd /home/runner/work/ollama/ollama/scripts/gh-agent-task
./demo.sh
```

This interactive demo shows all features with example output.

## Run Tests

```bash
cd /home/runner/work/ollama/ollama/scripts/gh-agent-task
./test.sh
```

Expected output: `All tests passed! ✓`

## Current Status

⚠️ **This is a prototype using mock data**

To integrate with real tasks:
1. Read `IMPLEMENTATION.md` for integration options
2. Choose: GitHub Actions, GitHub Issues, or Custom API
3. Follow the step-by-step guide
4. Replace mock data functions with real API calls

## Next Steps

- **Read**: `README.md` for full documentation
- **Integrate**: Follow `IMPLEMENTATION.md` for your chosen backend
- **Examples**: Check `examples/` directory
- **Customize**: Modify for your specific needs

## Support

- File issues in the Ollama repository
- Check documentation in this directory
- Run `gh agent-task --help` for command reference

## Commands Reference

| Command | Description |
|---------|-------------|
| `view <id>` | View task details |
| `view <id> --log` | View task with logs |
| `view <id> --json` | JSON output |
| `list` | List all tasks |
| `logs <id>` | View task logs only |
| `version` | Show version |
| `--help` | Show help |

---

**Ready to start?** Run `./demo.sh` to see it in action!
