# /sync-arch — Update Architecture Documentation

Focused update of `ARCHITECTURE.md`. Use after structural changes (new components, config changes, dependency updates).

## Arguments

Parse `$ARGUMENTS`:
- If empty: use current working directory
- If a local path: use that directory
- `--push`: auto-push after commit
- `--project <name>`: scope to `docs/<name>/ARCHITECTURE.md`

Examples:
```
/sync-arch
/sync-arch ~/my-project --push
/sync-arch ~/infra-docs --project gb10 --push
```

## Steps
1. Parse arguments, determine target path
2. Read existing `ARCHITECTURE.md` (create if missing)
3. Scan conversation and codebase for architectural changes:
   - New/removed components
   - Changed data flows
   - Config changes (read actual config files, not from memory)
   - Dependency version changes
4. Update ARCHITECTURE.md (merge, preserve valid existing content)
5. Git add + commit: `docs: architecture update [YYYY-MM-DD HH:MM]`
6. If `--push`: git push
7. Summary of architectural changes captured
