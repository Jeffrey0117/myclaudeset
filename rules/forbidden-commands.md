# FORBIDDEN COMMANDS (CRITICAL)

## ⛔ NEVER USE THESE COMMANDS

These commands will kill ALL Node/Electron processes including Claude Code itself:

```bash
# FORBIDDEN - Kills ALL Node processes
taskkill /F /IM node.exe
taskkill //F //IM node.exe

# FORBIDDEN - Kills ALL Electron processes
taskkill /F /IM electron.exe
taskkill //F //IM electron.exe

# FORBIDDEN - PowerShell variants
Get-Process node | Stop-Process
Stop-Process -Name node

# FORBIDDEN - Unix variants
pkill node
killall node
```

## ✅ ALWAYS USE INSTEAD

### Option 1: Use /kill skill (RECOMMENDED)
```bash
/kill 3000    # Kills process on port 3000 only
```

### Option 2: Manual precision kill
```bash
# 1. Find specific PID using port
netstat -ano | findstr :3000

# 2. Kill ONLY that specific PID
taskkill /F /PID 12345
```

### Option 3: Ask user first
If you must kill processes, ASK the user for confirmation first.

## HARD RULE

Before ANY `taskkill` command:
1. ✅ Use `/kill` skill if available
2. ✅ OR verify PID belongs to target app only
3. ✅ OR get explicit user confirmation
4. ❌ NEVER use `/IM node.exe` or `/IM electron.exe`

## WHY THIS MATTERS

- Claude Code runs on Node.js
- User may have multiple important Node.js windows open
- Killing all Node processes = killing Claude Code = session lost
- User's work gets interrupted and frustrated

## ENFORCEMENT

A PreToolUse hook (`block-node-kill.js`) will BLOCK these commands automatically.
If you try to use them, you will get an error message.
