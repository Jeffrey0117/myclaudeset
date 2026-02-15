---
name: git-advanced
description: 進階 Git 操作模式。Rebase、cherry-pick、conflict resolution、stash、worktree 的正確用法。
---

# Git Advanced Patterns

## Interactive Rebase

```bash
# Squash last 3 commits
git rebase -i HEAD~3

# Rebase onto main (update feature branch)
git fetch origin
git rebase origin/main
```

### Rebase 衝突處理
```bash
# 1. Fix conflicts in files
# 2. Stage fixed files
git add <files>
# 3. Continue rebase
git rebase --continue
# 4. If it's hopeless
git rebase --abort
```

## Cherry Pick

```bash
# Pick one commit from another branch
git cherry-pick <commit-hash>

# Pick without committing (stage only)
git cherry-pick --no-commit <hash>

# Pick a range
git cherry-pick <oldest>..<newest>
```

## Stash Patterns

```bash
# Stash with message
git stash push -m "WIP: feature X"

# Stash specific files
git stash push -m "partial" -- file1.ts file2.ts

# List stashes
git stash list

# Apply and keep
git stash apply stash@{0}

# Apply and remove
git stash pop

# Show stash contents
git stash show -p stash@{0}
```

## Conflict Resolution

### Strategy
1. **Understand both sides** — don't blindly pick one
2. **Check git log** — understand why each change was made
3. **Test after resolving** — run the full test suite

### Tools
```bash
# See conflict details
git diff --check

# Use merge tool
git mergetool

# Accept theirs / ours for specific file
git checkout --theirs <file>
git checkout --ours <file>
```

## Worktrees

```bash
# Create worktree for a branch
git worktree add ../my-feature feature-branch

# List worktrees
git worktree list

# Remove when done
git worktree remove ../my-feature
```

## Recovery

```bash
# Undo last commit (keep changes)
git reset --soft HEAD~1

# Find lost commits
git reflog

# Restore deleted branch
git checkout -b recovered <reflog-hash>

# Unstage file
git restore --staged <file>

# Discard changes in file
git restore <file>
```

## Useful Aliases

```bash
git log --oneline --graph --all    # Visual branch history
git diff --stat                     # Summary of changes
git log --author="name" --oneline  # Commits by author
git shortlog -sn                   # Commit count by author
```

## Rules

- **Never force push to main/master**
- **Never rebase shared/public branches**
- **Always pull before push**
- **Commit messages: type(scope): description**
