---
name: ctx-load
description: "Load saved project context docs back into the conversation. Trigger when the user says 'load context', 'recall', 'what were we working on', 'restore context', 'catch me up', 'where did we leave off', 'refresh context', or any variation. Also trigger proactively at session start when docs exist, after context compaction, or when the user seems to be missing context about the project. This reads all saved docs and outputs them so the conversation has full project context."
argument-hint: "[path] [--project name] [--docs-repo path]"
disable-model-invocation: true
---

# Load Saved Context from Project Docs

Read all saved documentation files and output them into the conversation so the current session has full project context. This is the counterpart to `/ctx-save` — save persists context, load restores it.

## Arguments

- No args → read from `<git-root>/docs/` (find root via `git rev-parse --show-toplevel`)
- Path → read from `<path>/docs/`
- `--project <name>` → read from `docs/<name>/`
- `--docs-repo <path>` → read from a separate repo (auto-derives `--project` from working repo basename)

```
/ctx-load                                      # <git-root>/docs/
/ctx-load ~/other-repo                         # ~/other-repo/docs/
/ctx-load --project myapp                      # <git-root>/docs/myapp/
/ctx-load --docs-repo ~/private-docs           # ~/private-docs/docs/<working-repo-name>/
```

## Target Resolution Order

Same as `/ctx-save`:

1. **Explicit `path` argument** → `<path>/docs/`
2. **`--docs-repo <path>` flag** → `<path>/docs/<project>/` (project = working repo basename)
3. **Config file entry** for current git root → use stored `path` + `project` from `~/.config/claude-skills/config.json`
4. **Default** → `<git-root>/docs/`

## Execution

1. Parse arguments, resolve target using resolution order above
2. Check which doc files exist in the target directory:
   - `STATUS.md`
   - `ARCHITECTURE.md`
   - `ENVIRONMENT.md`
   - `TROUBLESHOOTING.md`
3. Read each existing file and output its contents, clearly labeled with the filename
4. If no docs found, report that no saved context exists and suggest running `/ctx-save`
5. After outputting, briefly summarize the current state based on what was loaded (active workstreams, recent changes, any blockers)
