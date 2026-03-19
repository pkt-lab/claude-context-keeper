# /sync-status — Quick Status Update

Lightweight version of /sync-docs. Only updates `STATUS.md` with current workstream status, recent changes, and blockers. Designed to be run frequently.

## Arguments

Parse `$ARGUMENTS`:
- If empty: use current working directory
- If a local path: use that directory
- `--push`: auto-push after commit
- `--project <name>`: scope to `docs/<name>/STATUS.md`

Examples:
```
/sync-status
/sync-status ~/my-project --push
/sync-status ~/infra-docs --project gb10 --push
```

## Steps
1. Parse arguments, determine target path
2. Read existing `STATUS.md` (create if missing)
3. Scan conversation for current work state, recent changes, blockers
4. Update STATUS.md (merge new info, preserve valid existing content)
5. Git add + commit: `docs: status update [YYYY-MM-DD HH:MM]`
6. If `--push`: git push
7. One-line summary of what changed
