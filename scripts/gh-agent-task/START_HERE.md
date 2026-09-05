# 🚀 START HERE - gh-agent-task

Welcome! This is your entry point to the `gh-agent-task` GitHub CLI extension.

## What is this?

A complete GitHub CLI extension for managing AI agent tasks. View task status, logs, and details from your command line.

```bash
$ gh agent-task view dd1fee47-abb8-4a9c-b18e-60b512427f5f --log

Task Details
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ID:          dd1fee47-abb8-4a9c-b18e-60b512427f5f
Status:      completed
Agent:       my-agent
Model:       claude-3.5-sonnet
...
```

## 🎯 Quick Actions (Pick One)

### 1. Try It Right Now (30 seconds)
```bash
./gh-agent-task view dd1fee47-abb8-4a9c-b18e-60b512427f5f --log
```

### 2. Watch the Demo (5 minutes)
```bash
./demo.sh
```

### 3. Run Tests (1 minute)
```bash
./test.sh
# Expected: All tests passed! ✅
```

### 4. Learn How to Use It (5 minutes)
```bash
cat QUICK_START.md
# Or open in your editor
```

## 📚 What's Inside?

| File | What It Does | Read If... |
|------|--------------|------------|
| **QUICK_START.md** | 5-min getting started | You want to use it now |
| **README.md** | Complete documentation | You want all the details |
| **IMPLEMENTATION.md** | Integration guide | You're building the backend |
| **SUMMARY.md** | Project overview | You want to understand what was built |
| **INDEX.md** | File navigation | You want to explore |
| **gh-agent-task** | Main executable | You want to see the code |
| **test.sh** | Test suite | You want to verify it works |
| **demo.sh** | Interactive demo | You want to see it in action |

## 🏃 Quick Start

### Option A: Use Directly
```bash
./gh-agent-task --help
./gh-agent-task view <task-id>
./gh-agent-task list
```

### Option B: Install as gh Extension
```bash
gh extension install .
gh agent-task --help
```

## ✅ What Works Right Now

- [x] View task details
- [x] View task logs
- [x] List all tasks
- [x] JSON output
- [x] Help system
- [x] Error handling
- [x] All tests passing

## ⚠️ Current Status

This is a **working prototype with mock data**. 

To use with real tasks, follow `IMPLEMENTATION.md` to integrate with:
- GitHub Actions artifacts
- GitHub Issues
- Custom REST API

## 🎓 Learning Path

1. **First Time Here?** → Read `QUICK_START.md`
2. **Want Details?** → Read `README.md`
3. **Building Backend?** → Read `IMPLEMENTATION.md`
4. **Want Context?** → Read `SUMMARY.md`
5. **See It Work?** → Run `./demo.sh`

## 📞 Need Help?

- **Commands**: `./gh-agent-task --help`
- **Issues**: Open in Ollama repository
- **Docs**: All in this directory

## 🎉 Next Steps

Choose your path:

### Path 1: Just Exploring
✓ You're done! Try the commands and demo.

### Path 2: Want to Use It
→ Read `QUICK_START.md` (5 minutes)
→ Install with `gh extension install .`

### Path 3: Building Integration
→ Read `IMPLEMENTATION.md` (30 minutes)
→ Choose your backend architecture
→ Follow step-by-step guide

### Path 4: Contributing
→ Read `SUMMARY.md` for context
→ Review code in `gh-agent-task`
→ Run tests with `./test.sh`

---

**Ready?** Pick a quick action above and start! 🚀
