---
name: debugging
description: 系統化除錯流程。遇到 bug、test failure、crash 時使用。先收集證據再提假設，避免亂猜亂改。
---

# Systematic Debugging

## When to Use
- Bug reports
- Test failures
- Runtime errors / crashes
- Unexpected behavior

## The Process

### 1. Reproduce (重現)
- Get exact steps to reproduce
- Confirm the expected vs actual behavior
- Note the environment (OS, Node version, browser, etc.)

### 2. Isolate (隔離)
- Find the smallest reproduction case
- Remove unrelated code/config
- Binary search: comment out half the code, narrow down

### 3. Gather Evidence (收集證據)
```bash
# Check logs
# Add targeted console.log / debugger statements
# Check network requests
# Check git blame — when was this code last changed?
git log --oneline -10 -- <file>
git diff HEAD~5 -- <file>
```

### 4. Form Hypothesis (建立假設)
Before changing ANY code:
- State your hypothesis clearly: "I believe X causes Y because Z"
- List 2-3 possible causes, ranked by likelihood
- Identify what evidence would confirm/deny each

### 5. Test Hypothesis (驗證假設)
- Change ONE thing at a time
- Verify the fix actually addresses the root cause, not just the symptom
- Run the full test suite after fixing

### 6. Prevent Recurrence (防止復發)
- Add a test that would have caught this bug
- Consider if similar bugs exist elsewhere
- Update documentation if the behavior was surprising

## Anti-Patterns (DO NOT)

| Bad | Good |
|-----|------|
| Change random things until it works | Form hypothesis first |
| Fix the symptom | Fix the root cause |
| Skip reproduction | Always reproduce first |
| Change multiple things at once | One change at a time |
| Delete error handling to "fix" errors | Understand why the error happens |
| `try { } catch { }` with empty catch | Log and handle the error |

## Common Debug Strategies

### Binary Search
```
Working commit ← → Broken commit
         git bisect start
         git bisect good <commit>
         git bisect bad <commit>
```

### Rubber Duck
Explain the problem out loud, line by line. The act of explaining often reveals the issue.

### Read the Error Message
Seriously. Read it. The answer is often in the stack trace.

### Check Recent Changes
```bash
git log --oneline -20
git diff HEAD~1
```
