# /sync-status — Quick Status Update

Lightweight version of /sync-docs. Only updates `STATUS.md` with current workstream status, recent changes, and blockers. Designed to be run frequently.

## Arguments

Parse `$ARGUMENTS`:
- If empty: write to `docs/` in current git repo root (`git rev-parse --show-toplevel`)
- If a local path: write to `<path>/docs/`
- `--push`: auto-push after commit
- `--project <name>`: scope to `docs/<name>/STATUS.md`

Examples:
```
/sync-status                                    # <git-root>/docs/STATUS.md
/sync-status --push                             # same + push
/sync-status ~/other-repo --push                # ~/other-repo/docs/STATUS.md + push
/sync-status ~/infra-docs --project myapp --push
```

## Steps
1. Parse arguments, resolve target to `<root>/docs/` directory
2. Read existing `docs/STATUS.md` (create if missing)
3. Scan conversation for current work state, recent changes, blockers
4. Update STATUS.md (merge new info, preserve valid existing content)
5. Git add + commit: `docs: status update [YYYY-MM-DD HH:MM]`
6. If `--push`: git push
7. One-line summary of what changed
