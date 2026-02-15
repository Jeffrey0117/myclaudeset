#!/bin/bash
# Install myclaudeset — symlink Claude Code config from this repo to ~/.claude/
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"

echo "Installing myclaudeset from: $SCRIPT_DIR"
echo "Target: $CLAUDE_DIR"

mkdir -p "$CLAUDE_DIR"

ITEMS="skills commands rules agents"

# Check if already installed (symlinks pointing to this repo)
ALREADY_LINKED=true
for dir in $ITEMS; do
  if [ -L "$CLAUDE_DIR/$dir" ]; then
    CURRENT_TARGET="$(readlink "$CLAUDE_DIR/$dir")"
    if [ "$CURRENT_TARGET" != "$SCRIPT_DIR/$dir" ]; then
      ALREADY_LINKED=false
      break
    fi
  else
    ALREADY_LINKED=false
    break
  fi
done

if [ "$ALREADY_LINKED" = true ]; then
  echo "Already installed! Symlinks are correct."
  echo "Just use 'git pull' to sync updates — no need to re-install."
  exit 0
fi

# Backup existing config (only real dirs, skip symlinks)
NEEDS_BACKUP=false
for dir in $ITEMS; do
  if [ -d "$CLAUDE_DIR/$dir" ] && [ ! -L "$CLAUDE_DIR/$dir" ]; then
    NEEDS_BACKUP=true
    break
  fi
done

if [ "$NEEDS_BACKUP" = true ] || { [ -f "$CLAUDE_DIR/settings.json" ] && [ ! -L "$CLAUDE_DIR/settings.json" ]; }; then
  BACKUP="$CLAUDE_DIR/backup-$(date +%Y%m%d%H%M%S)"
  echo "Backing up existing config to: $BACKUP"
  mkdir -p "$BACKUP"
  for dir in $ITEMS; do
    if [ -d "$CLAUDE_DIR/$dir" ] && [ ! -L "$CLAUDE_DIR/$dir" ]; then
      cp -r "$CLAUDE_DIR/$dir" "$BACKUP/"
    fi
  done
  if [ -f "$CLAUDE_DIR/settings.json" ] && [ ! -L "$CLAUDE_DIR/settings.json" ]; then
    cp "$CLAUDE_DIR/settings.json" "$BACKUP/"
  fi
fi

# Remove existing and create symlinks
for dir in $ITEMS; do
  rm -rf "$CLAUDE_DIR/$dir"
  ln -sf "$SCRIPT_DIR/$dir" "$CLAUDE_DIR/$dir"
  echo "  Linked: $dir"
done

# Settings file
rm -f "$CLAUDE_DIR/settings.json"
ln -sf "$SCRIPT_DIR/settings.json" "$CLAUDE_DIR/settings.json"
echo "  Linked: settings.json"

echo ""
echo "Done! Claude Code config is now synced from this repo."
echo "After this, just 'git pull' to get updates — no need to re-install."
