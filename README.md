# claude-context-keeper

Keep track of what Claude did — so the next session doesn't start from scratch.

## Problem

When Claude's context gets compacted, the session ends, or you start a fresh agent, all the work context is gone — architecture decisions, environment details, debugging history, current status. These skills automatically persist that knowledge to structured markdown files in your project's `docs/` directory. Any future Claude session can read them and pick up exactly where the last one left off.

## Skills

### `/ctx-save [path] [--push] [--project name] [--docs-repo path] [--save-config]`
Save current work context to docs. Updates all 4 files (STATUS, ARCHITECTURE, ENVIRONMENT, TROUBLESHOOTING), skipping any where nothing meaningful changed. Run at task boundaries, before compaction, after debugging sessions, or whenever you want to checkpoint progress.

### `/ctx-load [path] [--project name] [--docs-repo path]`
Load saved context back into the conversation. Reads all doc files and outputs them so the session has full project context. Run at session start, after compaction, or when you need to recall what was happening.

### Options

| Flag | Description |
|------|-------------|
| `--push` | Auto `git push` after commit (ctx-save only) |
| `--project <name>` | Scope docs under `docs/<name>/` subdirectory |
| `--docs-repo <path>` | Write/read docs from a separate repo (auto-derives project from working repo basename) |
| `--save-config` | Persist `--docs-repo` mapping for this working repo in `~/.config/claude-skills/config.json` (ctx-save only) |

## Installation

### Via plugin marketplace (recommended)

```bash
# Add as a marketplace source
/plugin marketplace add pkt-lab/claude-context-keeper

# Then install
/plugin install context-keeper@pkt-lab-claude-context-keeper
```

After installing as a plugin, skills are namespaced: `/context-keeper:ctx-save`, `/context-keeper:ctx-load`.

### Via git clone + symlink

```bash
git clone https://github.com/pkt-lab/claude-context-keeper.git ~/claude-context-keeper
cd ~/claude-context-keeper && ./install.sh
```

This creates symlinks in `~/.claude/skills/` so skills appear as `/ctx-save`, `/ctx-load`.

### Manual

```bash
mkdir -p ~/.claude/skills
ln -sfn ~/claude-context-keeper/skills/ctx-save ~/.claude/skills/ctx-save
ln -sfn ~/claude-context-keeper/skills/ctx-load ~/.claude/skills/ctx-load
```

## Usage

```bash
# Save context to <git-root>/docs/
/ctx-save

# Save with auto-push
/ctx-save --push

# Save to a different repo
/ctx-save ~/other-repo

# Multi-project repo
/ctx-save ~/infra-docs --project myapp --push

# Load context at session start
/ctx-load

# Load from a specific project
/ctx-load --project myapp
```

## Private Docs Repo

For public/open-source repos where environment details, hardware specs, or debugging history shouldn't be committed publicly, write docs to a **separate private repo**.

### Setup

```bash
# One-time: save the mapping so future runs auto-resolve
/ctx-save --docs-repo ~/private-docs --save-config

# From now on, bare commands auto-resolve via config
/ctx-save           # → ~/private-docs/docs/my-public-app/
/ctx-load           # → ~/private-docs/docs/my-public-app/

# One-off without saving
/ctx-save --docs-repo ~/private-docs
```

### How It Works

- Config is stored in `~/.config/claude-skills/config.json` (invisible to public repos)
- Project name is auto-derived from the working repo's directory basename
- Source context (git log, code, services) is always gathered from the **working repo**
- Writes, commits, and pushes happen in the **docs repo**
- Commit messages include `Source: <working-repo-path>` for traceability

## Output Structure

```
<project-root>/
├── src/
├── docs/                 # created by /ctx-save
│   ├── STATUS.md         # workstreams, recent changes, blockers
│   ├── ARCHITECTURE.md   # components, data flow, config, deps
│   ├── ENVIRONMENT.md    # hardware, software, services, network
│   └── TROUBLESHOOTING.md # known issues, root causes, fixes
├── CLAUDE.md
└── ...

# With --project myapp:
<target>/
└── docs/
    └── myapp/
        ├── STATUS.md
        └── ...

# With --docs-repo ~/private-docs (from working repo "my-public-app"):
~/private-docs/
└── docs/
    └── my-public-app/
        ├── STATUS.md
        ├── ARCHITECTURE.md
        ├── ENVIRONMENT.md
        └── TROUBLESHOOTING.md
```

Decisions are recorded in **git commit messages** — `git log` is the decision history.

## Repo Structure

```
claude-context-keeper/
├── .claude-plugin/
│   └── plugin.json            # plugin manifest for marketplace install
├── skills/
│   ├── ctx-save/SKILL.md      # save context to docs
│   └── ctx-load/SKILL.md      # load context from docs
├── install.sh                 # symlink installer (alternative to plugin)
├── LICENSE
└── README.md
```

## Design Principles

- **Merge, don't overwrite** — new info is merged with existing content
- **Selective update** — only touch files with meaningful changes
- **Decisions in commits** — rich commit messages with context/rationale
- **Be specific** — exact versions, ports, paths, config values
- **Record "why"** — every change includes rationale
- **No secrets** — never write API keys, tokens, or passwords

## License

MIT
