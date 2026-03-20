---
name: ctx-save
description: "IMPORTANT: Use this skill to persist work context to structured docs that survive compaction and context resets. Trigger whenever the user says 'sync', 'save state', 'save context', 'update docs', 'persist context', 'write it down', 'checkpoint', 'save progress', or any variation. Also trigger proactively before compaction, at natural task boundaries, after major debugging sessions, when switching tasks, ending a session, or when significant changes were made. Updates all 4 doc files (STATUS, ARCHITECTURE, ENVIRONMENT, TROUBLESHOOTING), skipping any where nothing meaningful changed."
argument-hint: "[path] [--push] [--project name] [--docs-repo path] [--save-config]"
disable-model-invocation: true
---

# Save Work Context to Project Docs

Capture the current work state and update structured documentation files in the project's `docs/` directory. These files let future sessions reconstruct full context after compaction or restart. Updates all 4 files, skipping any where nothing meaningful changed.

## Arguments

- No args → write to `<git-root>/docs/` (find root via `git rev-parse --show-toplevel`)
- Path → write to `<path>/docs/`
- `--push` → git push after commit
- `--project <name>` → scope under `docs/<name>/`
- `--docs-repo <path>` → write docs to a separate repo (auto-derives `--project` from working repo basename)
- `--save-config` → persist the current `--docs-repo` mapping so future runs auto-resolve

```
/ctx-save                                      # <git-root>/docs/
/ctx-save --push                               # same + push
/ctx-save ~/other-repo                         # ~/other-repo/docs/
/ctx-save ~/infra-docs --project myapp --push  # ~/infra-docs/docs/myapp/ + push
/ctx-save --docs-repo ~/private-docs --save-config  # save mapping + write
/ctx-save --docs-repo ~/private-docs           # one-off write to private repo
```

## Private Docs Repo

For public/open-source repos where you don't want environment details, hardware specs, or debugging history committed publicly, use a **private docs repo** as the write target.

### One-Time Setup

```bash
/ctx-save --docs-repo ~/private-docs --save-config
```

This persists the mapping in `~/.config/claude-skills/config.json`. All future bare `/ctx-save` runs from this working repo will auto-resolve to the private docs repo.

### Config File

Location: `~/.config/claude-skills/config.json`

```json
{
  "docs-repo": {
    "/home/nvidia/projects/my-public-app": {
      "path": "/home/nvidia/private-docs",
      "project": "my-public-app"
    }
  }
}
```

### Target Resolution Order

1. **Explicit `path` argument** → `<path>/docs/`
2. **`--docs-repo <path>` flag** → `<path>/docs/<project>/` (project = working repo basename)
3. **Config file entry** for current git root → use stored `path` + `project`
4. **Default** → `<git-root>/docs/`

### Git Operations for Remote Docs Repo

When the target is outside the working repo:
- **Source context** (git log, code reading, services) is always gathered from the **working repo**
- **Write + commit + push** happens in the **docs repo** using `git -C <docs-repo>`
- Commit message format: `docs(<project-name>): update [YYYY-MM-DD HH:MM]`
- Commit message includes `Source: <working-repo-path>` in the body for traceability

## Files to Update

Only update files where you have meaningful new information. Read existing files first and merge — stale-but-valid content should stay. Skip files entirely if nothing changed.

### STATUS.md — What's happening now

Active workstreams, recent changes, pending/blocked items, known issues. This is the file someone reads first to get oriented.

Use checkboxes for workstreams. Be specific about what's done and what remains:
```markdown
- [x] Built TC3 firmware stack (RSE, SCP, TF-A, U-Boot, Linux)
- [ ] Android build — blocked on Docker installation
- [ ] Performance benchmarking — not started
```

Date-stamp recent changes with enough detail to reconstruct context:
```markdown
## Recent Changes
- **2026-03-19**: Built and booted Linux 6.1.75 on FVP_TC3 with buildroot rootfs
- **2026-03-19**: Patched build-linux.sh to bypass Kleaf/Bazel (forced make path)
```

Include blockers with what's stuck and why. Note workarounds if any exist.

### ARCHITECTURE.md — How the system works

Overview paragraph, component table, data flow, key configuration, external dependencies.

Component table with location, purpose, and status:
```markdown
| Component | Location | Purpose | Status |
|-----------|----------|---------|--------|
| RSE Firmware | src/rse/ | Hardware Root of Trust (Cortex-M55) | Built |
| SCP Firmware | src/SCP-firmware/ | Power/clock management (Cortex-M85) | Built |
```

Critical config files with their important settings and why they matter:
```markdown
**build-scripts/config/tc3.config**: Platform-specific build options
- `SCP_PLATFORM_VARIANT=MPMM` — enables Maximum Power Point Management
- `TC_GPU_VARIANT_ID=tkrx` — selects Mali-G725 (Krake) GPU model
```

External dependencies with pinned versions — "latest" is meaningless after compaction.

### ENVIRONMENT.md — Where it runs

Hardware specs, OS/kernel/package versions, running services with ports, network notes, auth methods (describe what exists, never include actual secrets — credentials in docs defeat the purpose of having docs).

### TROUBLESHOOTING.md — What went wrong and how to fix it

Each entry: symptom, root cause, fix, prevention. This is the most valuable file after a long debugging session — capture the fix while it's fresh.

## How to Write Good Docs

**Be specific.** Future-you after compaction only has what's written here. "Changed the config" is useless. "Changed `contextTokens` from 120000 to 200000 in `~/.openclaw/openclaw.json` because 120k caused timeout at 300s" is useful.

**Include rationale.** For every config value, architectural choice, or workaround — explain why. This context is exactly what gets lost during compaction and is hardest to reconstruct.

**Merge, don't replace.** Read existing content first. New info gets added or updates stale sections. Don't delete valid content just because it wasn't part of this session.

**Commit messages are the decision log.** Write them with context and rationale:
```
docs: update architecture after adding redis cache

Context: API latency exceeded 500ms p99 under load
Alternatives: considered in-memory LRU (insufficient for multi-process),
  Memcached (less feature-rich), decided on Redis for pub/sub support
```
This means `git log` serves as the decision history — no separate decisions file needed.

## Execution

1. Parse arguments, resolve target using resolution order above:
   - If `--docs-repo` given: target = `<docs-repo>/docs/<project>/` (project defaults to working repo basename)
   - Else if config entry exists for current git root: use stored path + project
   - Else if explicit path: target = `<path>/docs/`
   - Else: target = `<git-root>/docs/`
   - If `--save-config`: write/update `~/.config/claude-skills/config.json` with the mapping
2. Gather context from the **working repo**: conversation, `git log --oneline -20`, running services, config files, environment — skip what's not relevant
3. Read existing docs in target
4. Update changed files only — skip files where nothing meaningful changed
5. Git operations:
   - If target is in a different repo: `git -C <docs-repo>` add → commit (format: `docs(<project>): update [YYYY-MM-DD HH:MM]`, body includes `Source: <working-repo-path>`) → push if `--push`
   - If target is in working repo: `git add` changed files → commit → push if `--push`
6. Output one-line-per-file summary of what changed
