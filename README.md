# claude-skills

Claude Code slash commands for persistent work context management.

## Problem

After compaction, context window reset, or long work sessions, Claude loses critical details — architecture decisions, environment specifics, debugging history, and work status. These commands persist knowledge to structured markdown files in any git repo, surviving any context loss.

## Commands

### `/sync-docs [path] [options]`
Full sync of all documentation: STATUS, ARCHITECTURE, ENVIRONMENT, DECISIONS, TROUBLESHOOTING.

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
mkdir -p ~/.claude/commands
ln -sf ~/claude-skills/commands/*.md ~/.claude/commands/
```

## Usage

```bash
# Sync to current working directory (must be a git repo)
/sync-docs
/sync-status
/sync-arch

# Sync to a specific repo
/sync-docs ~/my-project
/sync-status ~/infra-docs

# Multi-project repo with auto-push
/sync-docs ~/infra-docs --project gb10 --push
/sync-status ~/infra-docs --project qnx-hv --push

# Just architecture, auto-push
/sync-arch ~/my-project --push
```

## Output Structure

```
<target>/
├── STATUS.md           # Active workstreams, recent changes, blockers
├── ARCHITECTURE.md     # Components, data flow, config, dependencies
├── ENVIRONMENT.md      # Hardware, software, services, network
├── DECISIONS.md        # Append-only decision log with rationale
└── TROUBLESHOOTING.md  # Known issues, root causes, fixes

# With --project gb10:
<target>/
└── docs/
    └── gb10/
        ├── STATUS.md
        ├── ARCHITECTURE.md
        └── ...
```

## Design Principles

- **Merge, don't overwrite** — new info is merged with existing content
- **Selective update** — only touch files with meaningful changes
- **Append-only decisions** — decision log never deletes entries
- **Be specific** — exact versions, ports, paths, config values
- **Record "why"** — every decision includes rationale
- **No secrets** — never write API keys, tokens, or passwords
- **Auto-commit + push** — git commit always, push with `--push`

## License

MIT
