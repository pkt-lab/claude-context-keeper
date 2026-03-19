# claude-skills

Claude Code slash commands for persistent work context management.

## Problem

After compaction, context window reset, or long work sessions, Claude loses critical details — architecture decisions, environment specifics, debugging history, and work status. These commands persist knowledge to structured markdown files in any git repo, surviving any context loss.

## Commands

### `/sync-docs [path] [options]`
Full sync of all documentation: STATUS, ARCHITECTURE, ENVIRONMENT, TROUBLESHOOTING.

### `/sync-status [path] [options]`
Quick update of STATUS.md only. Lightweight, run frequently.

### `/sync-arch [path] [options]`
Update ARCHITECTURE.md only. Run after structural changes.

### Options (all commands)

| Flag | Description |
|------|-------------|
| `--push` | Auto `git push` after commit |
| `--project <name>` | Scope docs under `docs/<name>/` subdirectory |

## Installation

```bash
git clone https://github.com/pkt-lab/claude-skills.git ~/claude-skills
cd ~/claude-skills && ./install.sh
```

Or manually:
```bash
mkdir -p ~/.claude/skills
ln -sfn ~/claude-skills/skills/sync-docs ~/.claude/skills/sync-docs
ln -sfn ~/claude-skills/skills/sync-status ~/.claude/skills/sync-status
ln -sfn ~/claude-skills/skills/sync-arch ~/.claude/skills/sync-arch
```

Restart Claude Code after installation to see the new `/sync-*` commands.

## Usage

```bash
# Default: writes to <git-root>/docs/ in current project
/sync-docs
/sync-status
/sync-arch

# With auto-push
/sync-docs --push

# Target a different repo
/sync-docs ~/other-repo
/sync-status ~/other-repo --push

# Multi-project repo
/sync-docs ~/infra-docs --project myapp --push
/sync-status ~/infra-docs --project backend --push
```

## Output Structure

By default, docs live alongside your code:

```
<project-root>/
├── src/
├── docs/                 # created by sync commands
│   ├── STATUS.md
│   ├── ARCHITECTURE.md
│   ├── ENVIRONMENT.md
│   └── TROUBLESHOOTING.md
├── CLAUDE.md
└── ...

# With --project myapp:
<target>/
└── docs/
    └── myapp/
        ├── STATUS.md
        ├── ARCHITECTURE.md
        └── ...
```

Decisions are recorded in **git commit messages** (not a separate file) — `git log` is the decision history.

## Design Principles

- **Merge, don't overwrite** — new info is merged with existing content
- **Selective update** — only touch files with meaningful changes
- **Decisions in commits** — rich commit messages with context/rationale replace a separate decision log
- **Be specific** — exact versions, ports, paths, config values
- **Record "why"** — every commit message includes rationale
- **No secrets** — never write API keys, tokens, or passwords
- **Auto-commit + push** — git commit always, push with `--push`

## License

MIT
