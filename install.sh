#!/bin/bash
# Install claude-skills into Claude Code
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_SKILLS_DIR="$HOME/.claude/skills"

mkdir -p "$CLAUDE_SKILLS_DIR"

for skill_dir in "$SCRIPT_DIR"/skills/*/; do
    name=$(basename "$skill_dir")
    ln -sfn "$skill_dir" "$CLAUDE_SKILLS_DIR/$name"
    echo "Linked: /$(echo "$name" | tr '-' '-')"
done

# Clean up legacy commands if they exist
if [ -d "$HOME/.claude/commands" ]; then
    for cmd in sync-docs sync-status sync-arch; do
        rm -f "$HOME/.claude/commands/${cmd}.md"
    done
fi

echo "Done. Restart Claude Code to see new slash commands."
