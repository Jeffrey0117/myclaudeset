#!/bin/bash
# Install myclaudeset — symlink Claude Code config from this repo to ~/.claude/
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"

echo "Installing myclaudeset from: $SCRIPT_DIR"
echo "Target: $CLAUDE_DIR"

# Backup existing config
if [ -d "$CLAUDE_DIR/skills" ] || [ -d "$CLAUDE_DIR/commands" ] || [ -d "$CLAUDE_DIR/rules" ] || [ -d "$CLAUDE_DIR/agents" ]; then
  BACKUP="$CLAUDE_DIR/backup-$(date +%Y%m%d%H%M%S)"
  echo "Backing up existing config to: $BACKUP"
  mkdir -p "$BACKUP"
  [ -d "$CLAUDE_DIR/skills" ] && cp -r "$CLAUDE_DIR/skills" "$BACKUP/"
  [ -d "$CLAUDE_DIR/commands" ] && cp -r "$CLAUDE_DIR/commands" "$BACKUP/"
  [ -d "$CLAUDE_DIR/rules" ] && cp -r "$CLAUDE_DIR/rules" "$BACKUP/"
  [ -d "$CLAUDE_DIR/agents" ] && cp -r "$CLAUDE_DIR/agents" "$BACKUP/"
  [ -f "$CLAUDE_DIR/settings.json" ] && cp "$CLAUDE_DIR/settings.json" "$BACKUP/"
fi

mkdir -p "$CLAUDE_DIR"

# Remove existing and create symlinks
for dir in skills commands rules agents; do
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
echo "Pull this repo on any machine and run install.sh to sync."
